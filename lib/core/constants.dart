// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:collection';

import 'package:flutter/services.dart';

import 'package:namida/class/lang.dart';
import 'package:namida/class/track.dart';
import 'package:namida/controller/indexer_controller.dart';
import 'package:namida/controller/settings_controller.dart';

///
int kSdkVersion = 21;

final Set<String> kStoragePaths = {};
final Set<String> kDirectoriesPaths = {};
final List<double> kDefaultWaveFormData = List<double>.filled(1, 2.0);
final List<double> kDefaultScaleList = List<double>.filled(1, 0.01);
final RegExp kYoutubeRegex = RegExp(
  r'\b(?:https?://)?(?:www\.)?(?:youtube\.com/watch\?v=|youtu\.be/)([\w\-]+)(?:\S+)?',
  caseSensitive: false,
);

/// Main Color
const Color kMainColor = Color.fromARGB(160, 117, 128, 224);
const Color kMainColorLight = Color.fromARGB(255, 116, 126, 219);
const Color kMainColorDark = Color.fromARGB(255, 139, 149, 241);

/// Files used by Namida
class AppPaths {
  static final _USER_DATA = AppDirs.USER_DATA;

  // ================= User Data =================
  static final SETTINGS = '$_USER_DATA/namida_settings.json';
  static final TRACKS = '$_USER_DATA/tracks.json';
  static final VIDEOS_LOCAL = '$_USER_DATA/local_videos.json';
  static final VIDEOS_CACHE = '$_USER_DATA/cache_videos.json';
  static final TRACKS_STATS = '$_USER_DATA/tracks_stats.json';
  static final LATEST_QUEUE = '$_USER_DATA/latest_queue.json';

  static final LOGS = '$_USER_DATA/logs.txt';

  static final TOTAL_LISTEN_TIME = '$_USER_DATA/total_listen.txt';
  static final FAVOURITES_PLAYLIST = '$_USER_DATA/favs.json';
  static final NAMIDA_LOGO = '${AppDirs.ARTWORKS}.ARTWORKS.NAMIDA_DEFAULT_ARTWORK.PNG';

  // ================= Youtube =================
  static final YT_FAVOURITES_PLAYLIST = '${AppDirs.YOUTUBE_MAIN_DIRECTORY}/ytfavs.json';
}

/// Directories used by Namida
class AppDirs {
  static String USER_DATA = '';
  static String APP_CACHE = '';
  static String INTERNAL_STORAGE = '';

  // ================= User Data =================
  static final HISTORY_PLAYLIST = '$USER_DATA/History/';
  static final PLAYLISTS = '$USER_DATA/Playlists/';
  static final QUEUES = '$USER_DATA/Queues/';
  static final ARTWORKS = '$USER_DATA/Artworks/'; // extracted audio artworks
  static final PALETTES = '$USER_DATA/Palettes/';
  static final VIDEOS_CACHE = '$USER_DATA/Videos/';
  static final AUDIOS_CACHE = '$USER_DATA/Audios/';
  static final VIDEOS_CACHE_TEMP = '$USER_DATA/Videos/Temp/';
  static final THUMBNAILS = '$USER_DATA/Thumbnails/'; // extracted video thumbnails
  static final LYRICS = '$USER_DATA/Lyrics/';

  // ================= Internal Storage =================
  static final SAVED_ARTWORKS = '$INTERNAL_STORAGE/Artworks/';
  static final BACKUPS = '$INTERNAL_STORAGE/Backups/';
  static final COMPRESSED_IMAGES = '$INTERNAL_STORAGE/Compressed/';

  // ================= Youtube =================
  static final YOUTUBE_MAIN_DIRECTORY = '$USER_DATA/Youtube';

  static final YT_PLAYLISTS = '$YOUTUBE_MAIN_DIRECTORY/Youtube Playlists/';
  static final YT_HISTORY_PLAYLIST = '$YOUTUBE_MAIN_DIRECTORY/Youtube History/';
  static final YT_THUMBNAILS = '$YOUTUBE_MAIN_DIRECTORY/YTThumbnails/';
  static final YT_THUMBNAILS_CHANNELS = '$YOUTUBE_MAIN_DIRECTORY/YTThumbnails Channels/';
  static final YT_METADATA = '$YOUTUBE_MAIN_DIRECTORY/Metadata Videos/';
  static final YT_METADATA_CHANNELS = '$YOUTUBE_MAIN_DIRECTORY/Metadata Channels/';
  static final YT_METADATA_COMMENTS = '$YOUTUBE_MAIN_DIRECTORY/Metadata Comments/';
  static final YT_STATS = '$YOUTUBE_MAIN_DIRECTORY/Youtube Stats/';
  static final YT_PALETTES = '$YOUTUBE_MAIN_DIRECTORY/Palettes/';

  // ===========================================
  static final List<String> values = [
    // -- User Data
    HISTORY_PLAYLIST,
    PLAYLISTS,
    QUEUES,
    ARTWORKS,
    PALETTES,
    VIDEOS_CACHE,
    VIDEOS_CACHE_TEMP,
    AUDIOS_CACHE,
    THUMBNAILS,
    LYRICS,
    // -- Youtube
    YOUTUBE_MAIN_DIRECTORY,
    YT_PLAYLISTS,
    YT_HISTORY_PLAYLIST,
    YT_THUMBNAILS,
    YT_THUMBNAILS_CHANNELS,
    YT_METADATA,
    YT_METADATA_CHANNELS,
    YT_METADATA_COMMENTS,
    YT_STATS,
    YT_PALETTES,
    // Internal Storage Directories are created on demand
  ];
}

class AppSocial {
  static const APP_VERSION = 'v1.0.0-release';
  static const DONATE_KOFI = 'https://ko-fi.com/namidaco';
  static const DONATE_BUY_ME_A_COFFEE = 'https://www.buymeacoffee.com/namidaco';
  static const GITHUB = 'https://github.com/namidaco/namida';
  static const GITHUB_ISSUES = '$GITHUB/issues';
  static const GITHUB_RELEASES = '$GITHUB/releases/';
  static const EMAIL = 'namida.coo@gmail.com';
}

/// Default Playlists IDs
const k_PLAYLIST_NAME_FAV = '_FAVOURITES_';
const k_PLAYLIST_NAME_HISTORY = '_HISTORY_';
const k_PLAYLIST_NAME_MOST_PLAYED = '_MOST_PLAYED_';
const k_PLAYLIST_NAME_AUTO_GENERATED = '_AUTO_GENERATED_';

List<Track> get allTracksInLibrary => UnmodifiableListView(Indexer.inst.tracksInfoList);

bool get shouldAlbumBeSquared =>
    (settings.albumGridCount.value > 1 && !settings.useAlbumStaggeredGridView.value) || (settings.albumGridCount.value == 1 && settings.forceSquaredAlbumThumbnail.value);

/// Stock Video Qualities List
final List<String> kStockVideoQualities = [
  '144p',
  '240p',
  '360p',
  '480p',
  '720p',
  '1080p',
  '2k',
  '4k',
  '8k',
];

/// Default values available for setting the Date Time Format.
const kDefaultDateTimeStrings = {
  'yyyyMMdd': '20220413',
  'dd/MM/yyyy': '13/04/2022',
  'MM/dd/yyyy': '04/13/2022',
  'yyyy/MM/dd': '2022/04/13',
  'yyyy/dd/MM': '2022/13/04',
  'dd-MM-yyyy': '13-04-2022',
  'MM-dd-yyyy': '04-13-2022',
  'MMMM dd, yyyy': 'April 13, 2022',
  'MMM dd, yyyy': 'Apr 13, 2022',
  '[dd | MM]': '[13 | 04]',
  '[dd.MM.yyyy]': '[13.04.2022]',
};

/// Extensions used to filter audio files
const List<String> kAudioFileExtensions = [
  '.aac',
  '.ac3',
  '.aiff',
  '.amr',
  '.ape',
  '.au',
  '.dts',
  '.flac',
  '.m4a',
  '.m4b',
  '.m4p',
  '.mid',
  '.mp3',
  '.ogg',
  '.opus',
  '.ra',
  '.tak',
  '.wav',
  '.wma',
];

/// Extensions used to filter video files
const List<String> kVideoFilesExtensions = [
  'mp4',
  'mkv',
  'avi',
  'wmv',
  'flv',
  'mov',
  '3gp',
  'ogv',
  'webm',
  'mpg',
  'mpeg',
  'm4v',
  'ts',
  'vob',
  'asf',
  'rm',
  'swf',
  'f4v',
  'divx',
  'm2ts',
  'mts',
  'mpv',
  'mp2',
  'mpe',
  'mpa',
  'mxf',
  'm2v',
  'mpeg1',
  'mpeg2',
  'mpeg4'
];
const kDefaultOrientations = <DeviceOrientation>[DeviceOrientation.portraitUp, DeviceOrientation.portraitDown];
const kDefaultLang = NamidaLanguage(
  code: "en_US",
  name: "English",
  country: "United States",
);

const kDummyTrack = Track('');
const kDummyExtendedTrack = TrackExtended(
  title: "",
  originalArtist: "",
  artistsList: [],
  album: "",
  albumArtist: "",
  originalGenre: "",
  genresList: [],
  composer: "",
  trackNo: 0,
  duration: 0,
  year: 0,
  size: 0,
  dateAdded: 0,
  dateModified: 0,
  path: "",
  comment: "",
  bitrate: 0,
  sampleRate: 0,
  format: "",
  channels: "",
  discNo: 0,
  language: "",
  lyrics: "",
);

/// Unknown Tag Fields
class UnknownTags {
  static const TITLE = '';
  static const ALBUM = 'Unknown Album';
  static const ALBUMARTIST = '';
  static const ARTIST = 'Unknown Artist';
  static const GENRE = 'Unknown Genre';
  static const COMPOSER = 'Unknown Composer';
}

int get currentTimeMS => DateTime.now().millisecondsSinceEpoch;

const kThemeAnimationDurationMS = 350;

const kMaximumSleepTimerTracks = 40;
const kMaximumSleepTimerMins = 180;
