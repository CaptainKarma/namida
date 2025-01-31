import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:namida/controller/indexer_controller.dart';
import 'package:namida/controller/navigator_controller.dart';
import 'package:namida/core/constants.dart';
import 'package:namida/core/extensions.dart';
import 'package:namida/core/translations/language.dart';
import 'package:namida/main.dart';

class BackupController {
  static BackupController get inst => _instance;
  static final BackupController _instance = BackupController._internal();
  BackupController._internal();

  final RxBool isCreatingBackup = false.obs;
  final RxBool isRestoringBackup = false.obs;

  Future<void> createBackupFile(List<String> backupItemsPaths) async {
    if (!await requestManageStoragePermission()) {
      return;
    }
    isCreatingBackup.value = true;

    // formats date
    final format = DateFormat('yyyy-MM-dd hh.mm.ss');
    final date = format.format(DateTime.now().toLocal());

    // creates directories and file
    final dir = await Directory(AppDirs.BACKUPS).create();
    await File("${dir.path}/Namida Backup - $date.zip").create();
    final sourceDir = Directory(AppDirs.USER_DATA);

    // prepares files

    final List<File> localFilesOnly = [];
    final List<File> youtubeFilesOnly = [];
    final List<File> compressedDirectories = [];
    final List<Directory> dirsOnly = [];
    File? tempAllLocal;
    File? tempAllYoutube;

    await backupItemsPaths.loopFuture((f, index) async {
      if (await FileSystemEntity.type(f) == FileSystemEntityType.file) {
        f.startsWith(AppDirs.YOUTUBE_MAIN_DIRECTORY) ? youtubeFilesOnly.add(File(f)) : localFilesOnly.add(File(f));
      }
      if (await FileSystemEntity.type(f) == FileSystemEntityType.directory) {
        dirsOnly.add(Directory(f));
      }
    });

    try {
      for (final d in dirsOnly) {
        try {
          final prefix = d.path.startsWith(AppDirs.YOUTUBE_MAIN_DIRECTORY) ? 'YOUTUBE_' : '';
          final dirZipFile = File("${AppDirs.USER_DATA}/${prefix}TEMPDIR_${d.path.getFilename}.zip");
          await ZipFile.createFromDirectory(sourceDir: d, zipFile: dirZipFile);
          compressedDirectories.add(dirZipFile);
        } catch (e) {
          continue;
        }
      }

      if (localFilesOnly.isNotEmpty) {
        tempAllLocal = await File("${AppDirs.USER_DATA}/LOCAL_FILES.zip").create();
        await ZipFile.createFromFiles(sourceDir: sourceDir, files: localFilesOnly, zipFile: tempAllLocal);
      }

      if (youtubeFilesOnly.isNotEmpty) {
        tempAllYoutube = await File("${AppDirs.USER_DATA}/YOUTUBE_FILES.zip").create();
        await ZipFile.createFromFiles(sourceDir: sourceDir, files: youtubeFilesOnly, zipFile: tempAllYoutube);
      }

      final zipFile = File("${AppDirs.BACKUPS}Namida Backup - $date.zip");
      final allFiles = [
        if (tempAllLocal != null) tempAllLocal,
        if (tempAllYoutube != null) tempAllYoutube,
        ...compressedDirectories,
      ];
      await ZipFile.createFromFiles(sourceDir: sourceDir, files: allFiles, zipFile: zipFile);

      snackyy(title: lang.CREATED_BACKUP_SUCCESSFULLY, message: lang.CREATED_BACKUP_SUCCESSFULLY_SUB);
    } catch (e) {
      printy(e, isError: true);
      snackyy(title: lang.ERROR, message: e.toString());
    }

    // Cleaning up
    tempAllLocal?.tryDeleting();
    tempAllYoutube?.tryDeleting();
    for (final d in compressedDirectories) {
      d.tryDeleting();
    }

    isCreatingBackup.value = false;
  }

  Future<void> restoreBackupOnTap(bool auto) async {
    if (!await requestManageStoragePermission()) {
      return;
    }
    NamidaNavigator.inst.closeDialog();
    File? backupzip;
    if (auto) {
      final dir = Directory(AppDirs.BACKUPS);
      final possibleFiles = dir.listSync();

      final List<File> filessss = [];
      possibleFiles.loop((pf, index) {
        if (pf.path.getFilename.startsWith('Namida Backup - ')) {
          if (pf is File) {
            filessss.add(pf);
          }
        }
      });

      // seems like the files are already sorted but anyways
      filessss.sortByReverse((e) => e.lastModifiedSync());
      backupzip = filessss.firstOrNull;
    } else {
      final filePicked = await FilePicker.platform.pickFiles(allowedExtensions: ['zip'], type: FileType.custom);
      final path = filePicked?.files.first.path;
      if (path != null) {
        backupzip = File(path);
      }
    }

    if (backupzip == null) return;

    isRestoringBackup.value = true;

    await ZipFile.extractToDirectory(zipFile: backupzip, destinationDir: Directory(AppDirs.USER_DATA));

    // after finishing, extracts zip files inside the main zip
    await for (final backupItem in Directory(AppDirs.USER_DATA).list()) {
      if (backupItem is File) {
        final filename = backupItem.path.getFilename;
        if (filename == 'LOCAL_FILES.zip') {
          await ZipFile.extractToDirectory(
            zipFile: backupItem,
            destinationDir: Directory(AppDirs.USER_DATA),
          );
          await backupItem.tryDeleting();
        } else if (filename == 'YOUTUBE_FILES.zip') {
          await ZipFile.extractToDirectory(
            zipFile: backupItem,
            destinationDir: Directory(AppDirs.USER_DATA), // since the zipped file has the directory 'AppDirs.YOUTUBE_MAIN_DIRECTORY/'
          );
          await backupItem.tryDeleting();
        } else {
          final isLocalTemp = filename.startsWith('TEMPDIR_');
          final isYoutubeTemp = filename.startsWith('YOUTUBE_TEMPDIR_');
          if (isLocalTemp || isYoutubeTemp) {
            final dir = isYoutubeTemp ? AppDirs.YOUTUBE_MAIN_DIRECTORY : AppDirs.USER_DATA;
            final prefixToReplace = isYoutubeTemp ? 'YOUTUBE_TEMPDIR_' : 'TEMPDIR_';

            await ZipFile.extractToDirectory(
              zipFile: backupItem,
              destinationDir: Directory("$dir/${filename.replaceFirst(prefixToReplace, '').replaceFirst('.zip', '')}"),
            );
            await backupItem.tryDeleting();
          }
        }
      }
    }

    Indexer.inst.refreshLibraryAndCheckForDiff();
    Indexer.inst.updateImageSizeInStorage();
    Indexer.inst.updateVideosSizeInStorage();
    snackyy(title: lang.RESTORED_BACKUP_SUCCESSFULLY, message: lang.RESTORED_BACKUP_SUCCESSFULLY_SUB);
    isRestoringBackup.value = false;
  }
}
