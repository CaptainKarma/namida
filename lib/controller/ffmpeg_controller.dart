import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_min/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_min/session_state.dart';
import 'package:get/get_rx/get_rx.dart';

import 'package:namida/class/media_info.dart';
import 'package:namida/class/track.dart';
import 'package:namida/controller/indexer_controller.dart';
import 'package:namida/controller/video_controller.dart';
import 'package:namida/core/constants.dart';
import 'package:namida/core/enums.dart';
import 'package:namida/core/extensions.dart';
import 'package:namida/main.dart';

class NamidaFFMPEG {
  static NamidaFFMPEG get inst => _instance;
  static final NamidaFFMPEG _instance = NamidaFFMPEG._internal();
  NamidaFFMPEG._internal() {
    FFmpegKitConfig.disableLogs();
  }
  final currentOperations = <OperationType, Rx<OperationProgress>>{
    OperationType.imageCompress: OperationProgress().obs,
    OperationType.ytdlpThumbnailFix: OperationProgress().obs,
  };

  Future<MediaInfo?> extractMetadata(String path) async {
    final session = await FFprobeKit.execute('-loglevel error -v quiet -show_entries stream_tags:format_tags -of json "$path"');
    final output = await session.getOutput();
    return output == null ? null : MediaInfo.fromMap(jsonDecode(output));
  }

  Future<bool> editMetadata({
    required String path,
    MIFormatTags? oldTags,
    required Map<FFMPEGTagField, String?> tagsMap,
    bool keepFileStats = true,
  }) async {
    final originalFile = File(path);
    final originalStats = keepFileStats ? await originalFile.stat() : null;
    final tempFile = await originalFile.copy("${AppDirs.INTERNAL_STORAGE}/.temp_${path.hashCode}");
    final tagsMapToEditConverted = <String, String?>{};
    for (final t in tagsMap.entries) {
      final fieldName = _defaultTagsMap[t.key];
      if (fieldName != null) tagsMapToEditConverted[fieldName] = t.value;
    }
    tagsMapToEditConverted.remove('dummy');

    if (tagsMap[FFMPEGTagField.trackNumber] != null || tagsMap[FFMPEGTagField.discNumber] != null) {
      oldTags ??= await extractMetadata(path).then((value) => value?.format?.tags);
      void plsAddDT(String valInMap, (String, String?)? trackOrDisc) {
        if (trackOrDisc != null) {
          final trackN = trackOrDisc.$1;
          final trackT = trackOrDisc.$2;
          if (trackT == null && trackN != "0") {
            tagsMapToEditConverted[valInMap] = trackN;
          } else if (trackT != null) {
            tagsMapToEditConverted[valInMap] = "${trackOrDisc.$1}/${trackOrDisc.$2}";
          }
        }
      }

      final trackNT = _trackAndDiscSplitter(oldTags?.track);
      final discNT = _trackAndDiscSplitter(oldTags?.disc);
      plsAddDT("track", (tagsMapToEditConverted["track"] ?? trackNT?.$1 ?? "0", trackNT?.$2));
      plsAddDT("disc", (tagsMapToEditConverted["disc"] ?? discNT?.$1 ?? "0", trackNT?.$2));
    }

    final tagsString = tagsMapToEditConverted.entries.map((e) => e.value == null ? '' : '-metadata ${e.key}="${e.value}"').join(' '); // check if need to remove empty value tag
    final didExecute = await _ffmpegExecute('-i "${tempFile.path}" $tagsString -c copy -y "$path"');
    // -- restoring original stats.
    if (originalStats != null) {
      await setFileStats(originalFile, originalStats);
    }
    await tempFile.tryDeleting();
    return didExecute;
  }

  Future<File?> extractAudioThumbnail({
    required String audioPath,
    required String thumbnailSavePath,
    bool compress = false,
    bool forceReExtract = false,
  }) async {
    if (!forceReExtract && await File(thumbnailSavePath).exists()) {
      return File(thumbnailSavePath);
    }

    final codec = compress ? '-filter:v scale=-2:250 -an' : '-c copy';
    final output = await FFmpegKit.execute('-i "$audioPath" -map 0:v -map -0:V $codec -y "$thumbnailSavePath"');
    final didSuccess = await output.getReturnCode().then((value) => value?.isValueSuccess()) ?? false;
    return didSuccess ? File(thumbnailSavePath) : null;
  }

  Future<bool> editAudioThumbnail({
    required String audioPath,
    required String thumbnailPath,
    bool keepOriginalFileStats = true,
  }) async {
    final audioFile = File(audioPath);
    final originalStats = keepOriginalFileStats ? await audioFile.stat() : null;

    final cacheFile = File("${AppDirs.APP_CACHE}/${audioPath.hashCode}.${audioPath.getExtension}");
    final output = await FFmpegKit.execute('-i "$audioPath" -i "$thumbnailPath" -map 0:a -map 1 -codec copy -disposition:v attached_pic -y "${cacheFile.path}"');
    final didSuccess = await output.getReturnCode().then((value) => value?.isValueSuccess()) ?? false;
    final canSafelyMoveBack = didSuccess && await cacheFile.sizeInBytes() > 0;
    if (canSafelyMoveBack) {
      // only move output file back in case of success.
      await cacheFile.copy(audioPath);

      if (originalStats != null) {
        await setFileStats(audioFile, originalStats);
      }
    }

    cacheFile.deleteIfExists();
    return canSafelyMoveBack;
  }

  Future<bool> setFileStats(File file, FileStat stats) async {
    try {
      await file.setLastAccessed(stats.accessed);
      await file.setLastModified(stats.modified);
      return true;
    } catch (e) {
      printy(e, isError: true);
      return false;
    }
  }

  Future<bool> compressImage({
    required String path,
    required String saveDir,
    bool keepOriginalFileStats = true,
    int percentage = 50,
  }) async {
    assert(percentage >= 0 && percentage <= 100);

    final toQSC = (percentage / 3.2).round();

    final imageFile = File(path);
    final originalStats = keepOriginalFileStats ? await imageFile.stat() : null;
    final newFilePath = "$saveDir/${path.getFilenameWOExt}.jpg";
    final output = await FFmpegKit.execute('-i "$path" -qscale:v $toQSC -y "$newFilePath"');
    final didSuccess = await output.getReturnCode().then((value) => value?.isValueSuccess()) ?? false;

    if (originalStats != null) {
      await setFileStats(File(newFilePath), originalStats);
    }

    return didSuccess;
  }

  Future<void> compressImageDirectories({
    required Iterable<String> dirs,
    required int compressionPerc,
    required bool keepOriginalFileStats,
    bool recursive = true,
  }) async {
    if (!await requestManageStoragePermission()) return;

    final dir = await Directory(AppDirs.COMPRESSED_IMAGES).create();

    final dirFiles = <FileSystemEntity>[];

    for (final d in dirs) {
      dirFiles.addAll(Directory(d).listSync(recursive: recursive));
    }

    dirFiles.retainWhere((element) => element is File);
    currentOperations[OperationType.imageCompress]!.value = OperationProgress(); // resetting

    final totalFiles = dirFiles.length;
    int currentProgress = 0;
    int currentFailed = 0;
    for (final f in dirFiles) {
      final didUpdate = await NamidaFFMPEG.inst.compressImage(
        path: f.path,
        saveDir: dir.path,
        percentage: compressionPerc,
        keepOriginalFileStats: keepOriginalFileStats,
      );
      if (!didUpdate) currentFailed++;
      currentProgress++;
      currentOperations[OperationType.imageCompress]!.value = OperationProgress(
        totalFiles: totalFiles,
        progress: currentProgress,
        currentFilePath: f.path,
        totalFailed: currentFailed,
      );
    }
    currentOperations[OperationType.imageCompress]!.value.currentFilePath = null;
  }

  Future<void> fixYTDLPBigThumbnailSize({required String directoryPath, bool recursive = true}) async {
    if (!await requestManageStoragePermission()) return;

    final dio = Dio();
    final allFiles = Directory(directoryPath).listSync(recursive: recursive);
    final totalFilesLength = allFiles.length;
    int currentProgress = 0;
    int currentFailed = 0;

    currentOperations[OperationType.ytdlpThumbnailFix]!.value = OperationProgress(); // resetting
    for (final filee in allFiles) {
      currentProgress++;
      if (filee is File) {
        final tr = await filee.path.toTrackExtOrExtract();
        final ytId = tr?.youtubeID;
        if (tr == null || ytId == null || ytId == '') continue;

        File? cachedThumbnail;

        cachedThumbnail = await VideoController.inst.getYoutubeThumbnailAndCache(id: ytId);

        if (cachedThumbnail == null) {
          currentFailed++;
        } else {
          final file = await Indexer.inst.extractOneArtwork(
            filee.path,
            forceReExtract: true,
            artworkPath: cachedThumbnail.path,
            albumIdendifier: tr.albumIdentifier,
          );
          if (file != null) {
            final didUpdate = await NamidaFFMPEG.inst.editAudioThumbnail(audioPath: filee.path, thumbnailPath: file.path);
            if (!didUpdate) currentFailed++;
          }
        }

        currentOperations[OperationType.ytdlpThumbnailFix]!.value = OperationProgress(
          totalFiles: totalFilesLength,
          progress: currentProgress,
          currentFilePath: filee.path,
          totalFailed: currentFailed,
        );
      }
    }
    dio.close();
    currentOperations[OperationType.ytdlpThumbnailFix]!.value.currentFilePath = null;
  }

  /// * Extracts thumbnail from a given video, usually this tries to get embed thumbnail,
  ///   if failed then it will extract a frame at a given duration.
  /// * [quality] & [atDuration] will not be used in case an embed thumbnail was found
  /// * [quality] ranges on a scale of 1-31, where 1 is the best & 31 is the worst.
  /// * if [atDuration] is not specified, it will try to calculate based on video duration
  ///   (typically thumbnail at duration of 10% of the original duration),
  ///   if failed then a thumbnail at Duration.zero will be extracted.
  Future<bool> extractVideoThumbnail({
    required String videoPath,
    required String thumbnailSavePath,
    int quality = 1,
    Duration? atDuration,
  }) async {
    assert(quality >= 1 && quality <= 31, 'quality ranges only between 1 & 31');

    int? atMillisecond = atDuration?.inMilliseconds;
    if (atMillisecond == null) {
      final duration = await getMediaDuration(videoPath);
      if (duration != null) atMillisecond = duration.inMilliseconds;
    }

    final didExecute = await _ffmpegExecute('-i "$videoPath" -map 0:v -map -0:V -c copy -y "$thumbnailSavePath"');
    if (didExecute) {
      return true;
    } else {
      final totalSeconds = (atMillisecond ?? 0) / 1000; // converting to decimal seconds.
      final extractFromSecond = totalSeconds * 0.1; // thumbnail at 10% of duration.
      return await _ffmpegExecute('-ss $extractFromSecond -i "$videoPath" -frames:v 1 -q:v $quality -y "$thumbnailSavePath"');
    }
  }

  Future<Duration?> getMediaDuration(String path) async {
    final session = await FFprobeKit.execute('-loglevel error -v quiet -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$path"');
    final output = await session.getOutput();
    final duration = output == null ? null : double.tryParse(output);
    return duration == null ? null : Duration(microseconds: (duration * 1000 * 1000).floor());
  }

  // Future<List<String>> getTrackAndDiscField(String path) async {
  //   await _ffprobeExecute('-v quiet -loglevel error -show_entries format_tags=track,disc -of default=noprint_wrappers=1:nokey=1 "$path"');
  //   final output = await _ffmpegConfig.getLastCommandOutput();
  //   return output.split('\n');
  // }

  Future<bool> mergeAudioAndVideo({
    required String videoPath,
    required String audioPath,
    required String outputPath,
    bool override = true,
  }) async {
    final ovrr = override ? '-y' : '';
    final res = await FFmpegKit.execute(' -i "$videoPath" -i "$audioPath" -c copy $ovrr "$outputPath"');
    return res.getState().then((value) => value == SessionState.completed);
  }

  Future<bool> _ffmpegExecute(String command) async {
    final res = await FFmpegKit.execute(command);
    final state = await res.getState();
    return state == SessionState.completed;
  }

  Future<bool> _ffprobeExecute(String command) async {
    final res = await FFprobeKit.execute(command);
    return await res.getState().then((value) => value == SessionState.completed);
  }

  /// First field is track/disc number, can be 0 or more.
  ///
  /// Second is track/disc total, can exist or can be null.
  ///
  /// Returns null if splitting failed or [discOrTrack] == null.
  (String, String?)? _trackAndDiscSplitter(String? discOrTrack) {
    if (discOrTrack != null) {
      final discNT = discOrTrack.split('/');
      if (discNT.length == 2) {
        // -- track/disc total exist
        final discN = discNT.first; // might be 0 or more
        final discT = discNT.last; // always more than 0
        return (discN, discT);
      } else if (discNT.length == 1) {
        // -- only track/disc number is provided
        final discN = discNT.first;
        return (discN, null);
      }
    }
    return null;
  }

  final _defaultTagsMap = <FFMPEGTagField, String>{
    FFMPEGTagField.year: "date",
    FFMPEGTagField.language: "LANGUAGE",
    FFMPEGTagField.artist: "artist",
    FFMPEGTagField.album: "album",
    FFMPEGTagField.composer: "composer",
    FFMPEGTagField.description: "description", // add
    FFMPEGTagField.remixer: "REMIXER",
    FFMPEGTagField.synopsis: "synopsis", // add
    FFMPEGTagField.title: "title",
    FFMPEGTagField.albumArtist: "album_artist",
    FFMPEGTagField.genre: "genre",
    FFMPEGTagField.country: "Country",
    FFMPEGTagField.recordLabel: "LABEL",
    FFMPEGTagField.comment: "comment",
    FFMPEGTagField.lyrics: "lyrics",
    FFMPEGTagField.lyricist: "LYRICIST",
    FFMPEGTagField.trackNumber: "track",
    FFMPEGTagField.discNumber: "disc",
  };
}

class OperationProgress {
  final int totalFiles;
  final int progress;
  String? currentFilePath;
  final int totalFailed;

  OperationProgress({
    this.totalFiles = 0,
    this.progress = 0,
    this.currentFilePath,
    this.totalFailed = 0,
  });
}

enum OperationType {
  imageCompress,
  ytdlpThumbnailFix,
}
