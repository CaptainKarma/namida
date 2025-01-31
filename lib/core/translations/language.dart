import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:namida/class/lang.dart';
import 'package:namida/controller/settings_controller.dart';
import 'package:namida/core/constants.dart';
import 'package:namida/core/extensions.dart';
import 'package:namida/core/namida_converter_ext.dart';
import 'package:namida/core/translations/keys.dart';

Language get lang => Language.inst;

class Language extends LanguageKeys {
  static Language get inst => _instance;
  static final Language _instance = Language._internal();
  Language._internal();

  static final Rx<NamidaLanguage> _currentLanguage = kDefaultLang.obs;

  /// Currently Selected & Set Language.
  NamidaLanguage get currentLanguage => _currentLanguage.value;

  /// All Available Languages fetched from `'/assets/language/translations/'`
  static late final List<NamidaLanguage> availableLanguages;

  /// Used as a backup in case a key wasn't found in the desired language.
  static late final Map<String, String> _defaultMap;

  static Future<void> initialize() async {
    final lang = settings.selectedLanguage.value;

    Future<void> updateAllAvailable() async {
      availableLanguages = await getAllLanguages();
    }

    // -- Assigning default map, used as a backup in case a key doesnt exist in [lang].
    final path = inst._getAssetPath(kDefaultLang);
    final map = await jsonDecode(await rootBundle.loadString(path)) as Map<String, dynamic>;
    _defaultMap = map.cast();
    // ---------

    await Future.wait([
      inst.update(
        lang: lang,
        trMap: lang.code == kDefaultLang.code ? _defaultMap : null,
      ),
      updateAllAvailable(),
    ]);
  }

  static Future<List<NamidaLanguage>> getAllLanguages() async {
    const path = 'assets/language/langs.json';
    final available = await rootBundle.loadString(path);
    final availableLangs = await jsonDecode(available) as List?;
    return availableLangs?.mapped((e) => NamidaLanguage.fromJson(e)) ?? [];
  }

  String _getAssetPath(NamidaLanguage lang) => 'assets/language/translations/${lang.code}.json';

  /// Returns false if there was a problem setting the language, for ex: lang file doesnt exist.
  Future<bool> update({required NamidaLanguage lang, Map<String, dynamic>? trMap}) async {
    // -- loading file from asset
    final path = _getAssetPath(lang);

    try {
      final map = trMap ?? await jsonDecode(await rootBundle.loadString(path)) as Map<String, dynamic>;
      String getKey(String key) => map[key] ?? _defaultMap[key] ?? '';

      // -- Keys Start ---------------------------------------------------------
			ABOUT = getKey("ABOUT");
			ACTIVE = getKey("ACTIVE");
			ADD_FOLDER = getKey("ADD_FOLDER");
			ADD_MORE_FROM_THIS_ALBUM = getKey("ADD_MORE_FROM_THIS_ALBUM");
			ADD_MORE_FROM_THIS_ARTIST = getKey("ADD_MORE_FROM_THIS_ARTIST");
			ADD_MORE_FROM_THIS_FOLDER = getKey("ADD_MORE_FROM_THIS_FOLDER");
			ADD_MORE_FROM_TO_QUEUE = getKey("ADD_MORE_FROM_TO_QUEUE");
			ADD_TO_PLAYLIST = getKey("ADD_TO_PLAYLIST");
			ADD = getKey("ADD");
			ADDED = getKey("ADDED");
			ADVANCED_SETTINGS_SUBTITLE = getKey("ADVANCED_SETTINGS_SUBTITLE");
			ADVANCED_SETTINGS = getKey("ADVANCED_SETTINGS");
			ADVANCED = getKey("ADVANCED");
			AGO = getKey("AGO");
			ALBUM_ARTIST = getKey("ALBUM_ARTIST");
			ALBUM_ARTISTS = getKey("ALBUM_ARTISTS");
			ALBUM_IDENTIFIERS = getKey("ALBUM_IDENTIFIERS");
			ALBUM_THUMBNAIL_SIZE_IN_LIST = getKey("ALBUM_THUMBNAIL_SIZE_IN_LIST");
			ALBUM_TILE_CUSTOMIZATION = getKey("ALBUM_TILE_CUSTOMIZATION");
			ALBUM = getKey("ALBUM");
			ALBUMS_COUNT = getKey("ALBUMS_COUNT");
			ALBUMS = getKey("ALBUMS");
			ALL_TIME = getKey("ALL_TIME");
			ALWAYS_ASK = getKey("ALWAYS_ASK");
			ANIMATING_THUMBNAIL_INTENSITY = getKey("ANIMATING_THUMBNAIL_INTENSITY");
			ANIMATING_THUMBNAIL_INVERSED_SUBTITLE = getKey("ANIMATING_THUMBNAIL_INVERSED_SUBTITLE");
			ANIMATING_THUMBNAIL_INVERSED = getKey("ANIMATING_THUMBNAIL_INVERSED");
			ANOTHER_PROCESS_IS_RUNNING = getKey("ANOTHER_PROCESS_IS_RUNNING");
			ARTIST = getKey("ARTIST");
			ARTISTS = getKey("ARTISTS");
			ARTWORK = getKey("ARTWORK");
			ARTWORKS = getKey("ARTWORKS");
			AUDIO = getKey("AUDIO");
			AUDIO_CACHE = getKey("AUDIO_CACHE");
			AUDIO_ONLY = getKey("AUDIO_ONLY");
			AUTO_COLORING_SUBTITLE = getKey("AUTO_COLORING_SUBTITLE");
			AUTO_COLORING = getKey("AUTO_COLORING");
			AUTO_EXTRACT_TAGS_FROM_FILENAME = getKey("AUTO_EXTRACT_TAGS_FROM_FILENAME");
			AUTO_GENERATED = getKey("AUTO_GENERATED");
			AUTO = getKey("AUTO");
			AUTOMATIC_BACKUP_SUBTITLE = getKey("AUTOMATIC_BACKUP_SUBTITLE");
			AUTOMATIC_BACKUP = getKey("AUTOMATIC_BACKUP");
			BACKUP_AND_RESTORE_SUBTITLE = getKey("BACKUP_AND_RESTORE_SUBTITLE");
			BACKUP_AND_RESTORE = getKey("BACKUP_AND_RESTORE");
			BETA = getKey("BETA");
			BETWEEN_DATES = getKey("BETWEEN_DATES");
			BITRATE = getKey("BITRATE");
			BLACKLIST = getKey("BLACKLIST");
			BORDER_RADIUS_MULTIPLIER = getKey("BORDER_RADIUS_MULTIPLIER");
			CACHE = getKey("CACHE");
			CANCEL = getKey("CANCEL");
			CHANGED = getKey("CHANGED");
			CHANGELOG = getKey("CHANGELOG");
			CHANNELS = getKey("CHANNELS");
			CHECK_FOR_MORE = getKey("CHECK_FOR_MORE");
			CHECK_LIST = getKey("CHECK_LIST");
			CHOOSE_WHAT_TO_CLEAR = getKey("CHOOSE_WHAT_TO_CLEAR");
			CHOOSE = getKey("CHOOSE");
			CLEAR_IMAGE_CACHE_WARNING = getKey("CLEAR_IMAGE_CACHE_WARNING");
			CLEAR_IMAGE_CACHE = getKey("CLEAR_IMAGE_CACHE");
			CLEAR_TRACK_ITEM_MULTIPLE = getKey("CLEAR_TRACK_ITEM_MULTIPLE");
			CLEAR_TRACK_ITEM = getKey("CLEAR_TRACK_ITEM");
			CLEAR_VIDEO_CACHE_NOTE = getKey("CLEAR_VIDEO_CACHE_NOTE");
			CLEAR_VIDEO_CACHE_SUBTITLE = getKey("CLEAR_VIDEO_CACHE_SUBTITLE");
			CLEAR_VIDEO_CACHE = getKey("CLEAR_VIDEO_CACHE");
			CLEAR = getKey("CLEAR");
			CLOCK = getKey("CLOCK");
			COLOR_PALETTE = getKey("COLOR_PALETTE");
			COLOR_PALETTES = getKey("COLOR_PALETTES");
			COLOR_PALETTE_NOTE_1 = getKey("COLOR_PALETTE_NOTE_1");
			COLOR_PALETTE_NOTE_2 = getKey("COLOR_PALETTE_NOTE_2");
			COMMENT = getKey("COMMENT");
			COMMENTS = getKey("COMMENTS");
			COMPOSER = getKey("COMPOSER");
			COMPRESS = getKey("COMPRESS");
			COMPRESSION_PERCENTAGE = getKey("COMPRESSION_PERCENTAGE");
			COMPRESS_IMAGES = getKey("COMPRESS_IMAGES");
			CONFIGURE = getKey("CONFIGURE");
			CONFIRM = getKey("CONFIRM");
			COPIED_ARTWORK = getKey("COPIED_ARTWORK");
			COPY = getKey("COPY");
			CORRUPTED_FILE = getKey("CORRUPTED_FILE");
			COULDNT_OPEN_YT_LINK = getKey("COULDNT_OPEN_YT_LINK");
			COULDNT_OPEN = getKey("COULDNT_OPEN");
			COULDNT_PLAY_FILE = getKey("COULDNT_PLAY_FILE");
			COULDNT_RENAME_PLAYLIST = getKey("COULDNT_RENAME_PLAYLIST");
			COULDNT_SAVE_IMAGE = getKey("COULDNT_SAVE_IMAGE");
			COUNTRY = getKey("COUNTRY");
			CREATE_BACKUP = getKey("CREATE_BACKUP");
			CREATE_NEW_PLAYLIST = getKey("CREATE_NEW_PLAYLIST");
			CREATE = getKey("CREATE");
			CREATED_BACKUP_SUCCESSFULLY_SUB = getKey("CREATED_BACKUP_SUCCESSFULLY_SUB");
			CREATED_BACKUP_SUCCESSFULLY = getKey("CREATED_BACKUP_SUCCESSFULLY");
			CUSTOM = getKey("CUSTOM");
			CUSTOMIZATIONS_SUBTITLE = getKey("CUSTOMIZATIONS_SUBTITLE");
			CUSTOMIZATIONS = getKey("CUSTOMIZATIONS");
			DATABASE = getKey("DATABASE");
			DATE_ADDED = getKey("DATE_ADDED");
			DATE_CREATED = getKey("DATE_CREATED");
			DATE_MODIFIED = getKey("DATE_MODIFIED");
			DATE_TIME_FORMAT = getKey("DATE_TIME_FORMAT");
			DATE = getKey("DATE");
			DAY = getKey("DAY");
			DAYS = getKey("DAYS");
			DEFAULT_BACKUP_LOCATION = getKey("DEFAULT_BACKUP_LOCATION");
			DEFAULT_COLOR_SUBTITLE = getKey("DEFAULT_COLOR_SUBTITLE");
			DEFAULT_COLOR = getKey("DEFAULT_COLOR");
			DEFAULT_LIBRARY_TAB = getKey("DEFAULT_LIBRARY_TAB");
			DEFAULT = getKey("DEFAULT");
			DELETE_PLAYLIST = getKey("DELETE_PLAYLIST");
			DELETE = getKey("DELETE");
			DESCRIPTION = getKey("DESCRIPTION");
			DIM_INTENSITY = getKey("DIM_INTENSITY");
			DIM_MINIPLAYER_AFTER_SECONDS = getKey("DIM_MINIPLAYER_AFTER_SECONDS");
			DIRECTORY_DOESNT_EXIST = getKey("DIRECTORY_DOESNT_EXIST");
			DISABLE_REORDERING = getKey("DISABLE_REORDERING");
			DISABLE_SEARCH_CLEANUP = getKey("DISABLE_SEARCH_CLEANUP");
			DISC_NUMBER_TOTAL = getKey("DISC_NUMBER_TOTAL");
			DISC_NUMBER = getKey("DISC_NUMBER");
			DISLIKE = getKey("DISLIKE");
			DISPLAY_ALBUM_CARD_TOP_RIGHT_DATE_SUBTITLE = getKey("DISPLAY_ALBUM_CARD_TOP_RIGHT_DATE_SUBTITLE");
			DISPLAY_ALBUM_CARD_TOP_RIGHT_DATE = getKey("DISPLAY_ALBUM_CARD_TOP_RIGHT_DATE");
			DISPLAY_AUDIO_INFO_IN_MINIPLAYER = getKey("DISPLAY_AUDIO_INFO_IN_MINIPLAYER");
			DISPLAY_FAV_BUTTON_IN_NOTIFICATION_SUBTITLE = getKey("DISPLAY_FAV_BUTTON_IN_NOTIFICATION_SUBTITLE");
			DISPLAY_FAV_BUTTON_IN_NOTIFICATION = getKey("DISPLAY_FAV_BUTTON_IN_NOTIFICATION");
			DISPLAY_FAVOURITE_ICON_IN_TRACK_TILE = getKey("DISPLAY_FAVOURITE_ICON_IN_TRACK_TILE");
			DISPLAY_REMAINING_DURATION_INSTEAD_OF_TOTAL = getKey("DISPLAY_REMAINING_DURATION_INSTEAD_OF_TOTAL");
			DISPLAY_THIRD_ITEM_IN_ROW_IN_TRACK_TILE = getKey("DISPLAY_THIRD_ITEM_IN_ROW_IN_TRACK_TILE");
			DISPLAY_THIRD_ROW_IN_TRACK_TILE = getKey("DISPLAY_THIRD_ROW_IN_TRACK_TILE");
			DISPLAY_TRACK_NUMBER_IN_ALBUM_PAGE_SUBTITLE = getKey("DISPLAY_TRACK_NUMBER_IN_ALBUM_PAGE_SUBTITLE");
			DISPLAY_TRACK_NUMBER_IN_ALBUM_PAGE = getKey("DISPLAY_TRACK_NUMBER_IN_ALBUM_PAGE");
			DONE = getKey("DONE");
			DONT_RESTORE_POSITION = getKey("DONT_RESTORE_POSITION");
			DOWNLOAD = getKey("DOWNLOAD");
			DOWNLOADING_WILL_OVERRIDE_IT = getKey("DOWNLOADING_WILL_OVERRIDE_IT");
			DOWNLOADS_METADATA_TAGS = getKey("DOWNLOADS_METADATA_TAGS");
			DOWNLOADS_METADATA_TAGS_SUBTITLE = getKey("DOWNLOADS_METADATA_TAGS_SUBTITLE");
			DO_NOTHING = getKey("DO_NOTHING");
			DUCK_AUDIO = getKey("DUCK_AUDIO");
			DUPLICATED_TRACKS = getKey("DUPLICATED_TRACKS");
			DURATION = getKey("DURATION");
			EDGE_COLORS_SWITCHING = getKey("EDGE_COLORS_SWITCHING");
			EDIT_ARTWORK = getKey("EDIT_ARTWORK");
			EDIT_TAGS = getKey("EDIT_TAGS");
			EMPTY_NON_MEANINGFUL_TAG_FIELDS = getKey("EMPTY_NON_MEANINGFUL_TAG_FIELDS");
			EMPTY_VALUE = getKey("EMPTY_VALUE");
			ENABLE_BLUR_EFFECT = getKey("ENABLE_BLUR_EFFECT");
			ENABLE_BOTTOM_NAV_BAR_SUBTITLE = getKey("ENABLE_BOTTOM_NAV_BAR_SUBTITLE");
			ENABLE_BOTTOM_NAV_BAR = getKey("ENABLE_BOTTOM_NAV_BAR");
			ENABLE_FADE_EFFECT_ON_PLAY_PAUSE = getKey("ENABLE_FADE_EFFECT_ON_PLAY_PAUSE");
			ENABLE_FOLDERS_HIERARCHY = getKey("ENABLE_FOLDERS_HIERARCHY");
			ENABLE_GLOW_EFFECT = getKey("ENABLE_GLOW_EFFECT");
			ENABLE_MINIPLAYER_PARTICLES = getKey("ENABLE_MINIPLAYER_PARTICLES");
			ENABLE_PARALLAX_EFFECT = getKey("ENABLE_PARALLAX_EFFECT");
			ENABLE_PARTY_MODE_SUBTITLE = getKey("ENABLE_PARTY_MODE_SUBTITLE");
			ENABLE_PARTY_MODE = getKey("ENABLE_PARTY_MODE");
			ENABLE_PICTURE_IN_PICTURE = getKey("ENABLE_PICTURE_IN_PICTURE");
			ENABLE_REORDERING = getKey("ENABLE_REORDERING");
			ENABLE_SEARCH_CLEANUP_SUBTITLE = getKey("ENABLE_SEARCH_CLEANUP_SUBTITLE");
			ENABLE_SEARCH_CLEANUP = getKey("ENABLE_SEARCH_CLEANUP");
			ENABLE_VIDEO_PLAYBACK = getKey("ENABLE_VIDEO_PLAYBACK");
			ENTER_SYMBOL = getKey("ENTER_SYMBOL");
			ERROR_PLAYING_TRACK = getKey("ERROR_PLAYING_TRACK");
			ERROR = getKey("ERROR");
			EXCLUDED_FODLERS = getKey("EXCLUDED_FODLERS");
			EXIT_APP_SUBTITLE = getKey("EXIT_APP_SUBTITLE");
			EXIT = getKey("EXIT");
			EXTENSION = getKey("EXTENSION");
			EXTERNAL_FILES = getKey("EXTERNAL_FILES");
			EXTRACT_ALL_COLOR_PALETTES_SUBTITLE = getKey("EXTRACT_ALL_COLOR_PALETTES_SUBTITLE");
			EXTRACT_ALL_COLOR_PALETTES = getKey("EXTRACT_ALL_COLOR_PALETTES");
			EXTRACT_FEAT_ARTIST_SUBTITLE = getKey("EXTRACT_FEAT_ARTIST_SUBTITLE");
			EXTRACT_FEAT_ARTIST = getKey("EXTRACT_FEAT_ARTIST");
			EXTRACT = getKey("EXTRACT");
			EXTRACTING_INFO = getKey("EXTRACTING_INFO");
			EXTRAS_SUBTITLE = getKey("EXTRAS_SUBTITLE");
			EXTRAS = getKey("EXTRAS");
			FAILED_EDITS = getKey("FAILED_EDITS");
			FAILED = getKey("FAILED");
			FAVOURITES = getKey("FAVOURITES");
			FILE_NAME_WO_EXT = getKey("FILE_NAME_WO_EXT");
			FILE_NAME = getKey("FILE_NAME");
			FILE = getKey("FILE");
			FILES = getKey("FILES");
			FILE_ALREADY_EXISTS = getKey("FILE_ALREADY_EXISTS");
			FILTER_ALBUMS = getKey("FILTER_ALBUMS");
			FILTER_ARTISTS = getKey("FILTER_ARTISTS");
			FILTER_GENRES = getKey("FILTER_GENRES");
			FILTER_PLAYLISTS = getKey("FILTER_PLAYLISTS");
			FILTER_TRACKS_BY = getKey("FILTER_TRACKS_BY");
			FILTER_TRACKS = getKey("FILTER_TRACKS");
			FILTERED_BY_SIZE_AND_DURATION = getKey("FILTERED_BY_SIZE_AND_DURATION");
			FINISHED_UPDATING_LIBRARY = getKey("FINISHED_UPDATING_LIBRARY");
			FIX_YTDLP_BIG_THUMBNAIL_SIZE = getKey("FIX_YTDLP_BIG_THUMBNAIL_SIZE");
			FOLDER_NAME = getKey("FOLDER_NAME");
			FOLDER = getKey("FOLDER");
			FOLDERS = getKey("FOLDERS");
			FONT_SCALE = getKey("FONT_SCALE");
			FORCE_SQUARED_ALBUM_THUMBNAIL = getKey("FORCE_SQUARED_ALBUM_THUMBNAIL");
			FORCE_SQUARED_THUMBNAIL_NOTE = getKey("FORCE_SQUARED_THUMBNAIL_NOTE");
			FORCE_SQUARED_TRACK_THUMBNAIL = getKey("FORCE_SQUARED_TRACK_THUMBNAIL");
			FORCE_STOP_COLOR_PALETTE_GENERATION = getKey("FORCE_STOP_COLOR_PALETTE_GENERATION");
			FORMAT = getKey("FORMAT");
			GENERATE_FROM_DATES_SUBTITLE = getKey("GENERATE_FROM_DATES_SUBTITLE");
			GENERATE_FROM_DATES = getKey("GENERATE_FROM_DATES");
			GENERATE = getKey("GENERATE");
			GENRE = getKey("GENRE");
			GENRES = getKey("GENRES");
			GO_TO_ALBUM = getKey("GO_TO_ALBUM");
			GO_TO_ARTIST = getKey("GO_TO_ARTIST");
			GO_TO_CHANNEL = getKey("GO_TO_CHANNEL");
			GO_TO_FOLDER = getKey("GO_TO_FOLDER");
			GRANT_ACCESS = getKey("GRANT_ACCESS");
			GROUP_ARTWORKS_BY_ALBUM = getKey("GROUP_ARTWORKS_BY_ALBUM");
			GUIDE = getKey("GUIDE");
			HEIGHT_OF_ALBUM_TILE = getKey("HEIGHT_OF_ALBUM_TILE");
			HEIGHT_OF_TRACK_TILE = getKey("HEIGHT_OF_TRACK_TILE");
			HIGH_MATCHES = getKey("HIGH_MATCHES");
			HISTORY = getKey("HISTORY");
			HISTORY_IMPORT_MISSING_ENTRIES_NOTE = getKey("HISTORY_IMPORT_MISSING_ENTRIES_NOTE");
			HISTORY_LISTENS_REPLACE_WARNING = getKey("HISTORY_LISTENS_REPLACE_WARNING");
			HOME = getKey("HOME");
			HOUR_FORMAT_12 = getKey("HOUR_FORMAT_12");
			IMPORT_ALL = getKey("IMPORT_ALL");
			IMPORT_LAST_FM_HISTORY_GUIDE = getKey("IMPORT_LAST_FM_HISTORY_GUIDE");
			IMPORT_LAST_FM_HISTORY = getKey("IMPORT_LAST_FM_HISTORY");
			IMPORT_TIME_RANGE = getKey("IMPORT_TIME_RANGE");
			IMPORT_YOUTUBE_HISTORY_GUIDE = getKey("IMPORT_YOUTUBE_HISTORY_GUIDE");
			IMPORT_YOUTUBE_HISTORY = getKey("IMPORT_YOUTUBE_HISTORY");
			INDEX_REFRESH_REQUIRED = getKey("INDEX_REFRESH_REQUIRED");
			INDEXER_NOTE = getKey("INDEXER_NOTE");
			INDEXER_SUBTITLE = getKey("INDEXER_SUBTITLE");
			INDEXER = getKey("INDEXER");
			INFINITY_QUEUE_ON_NEXT_PREV = getKey("INFINITY_QUEUE_ON_NEXT_PREV");
			INFINITY_QUEUE_ON_NEXT_PREV_SUBTITLE = getKey("INFINITY_QUEUE_ON_NEXT_PREV_SUBTITLE");
			INSERTED = getKey("INSERTED");
			INSTANTLY_APPLIES = getKey("INSTANTLY_APPLIES");
			ITEM = getKey("ITEM");
			JUMP_TO_DAY = getKey("JUMP_TO_DAY");
			JUMP_TO_FIRST_TRACK_AFTER_QUEUE_FINISH = getKey("JUMP_TO_FIRST_TRACK_AFTER_QUEUE_FINISH");
			JUMP = getKey("JUMP");
			KEEP_CACHED_VERSIONS = getKey("KEEP_CACHED_VERSIONS");
			KEEP_FILE_DATES = getKey("KEEP_FILE_DATES");
			KEEP_SCREEN_AWAKE_MINIPLAYER_EXPANDED_AND_VIDEO = getKey("KEEP_SCREEN_AWAKE_MINIPLAYER_EXPANDED_AND_VIDEO");
			KEEP_SCREEN_AWAKE_MINIPLAYER_EXPANDED = getKey("KEEP_SCREEN_AWAKE_MINIPLAYER_EXPANDED");
			KEEP_SCREEN_AWAKE_NONE = getKey("KEEP_SCREEN_AWAKE_NONE");
			KEEP_SCREEN_AWAKE_WHEN = getKey("KEEP_SCREEN_AWAKE_WHEN");
			LANGUAGE = getKey("LANGUAGE");
			LIBRARY_TABS_REORDER = getKey("LIBRARY_TABS_REORDER");
			LIBRARY_TABS = getKey("LIBRARY_TABS");
			LIKE = getKey("LIKE");
			LINK = getKey("LINK");
			LIST_OF_FOLDERS = getKey("LIST_OF_FOLDERS");
			LOADING_FILE = getKey("LOADING_FILE");
			LOCAL = getKey("LOCAL");
			LOCAL_VIDEO_MATCHING = getKey("LOCAL_VIDEO_MATCHING");
			LOST_MEMORIES = getKey("LOST_MEMORIES");
			LOST_MEMORIES_SUBTITLE = getKey("LOST_MEMORIES_SUBTITLE");
			LYRICIST = getKey("LYRICIST");
			LYRICS = getKey("LYRICS");
			MAKE_YOUR_FIRST_LISTEN = getKey("MAKE_YOUR_FIRST_LISTEN");
			MANUAL_BACKUP_SUBTITLE = getKey("MANUAL_BACKUP_SUBTITLE");
			MANUAL_BACKUP = getKey("MANUAL_BACKUP");
			MATCHING_TYPE = getKey("MATCHING_TYPE");
			MATCH_ALL_TRACKS = getKey("MATCH_ALL_TRACKS");
			MATCH_ALL_TRACKS_NOTE = getKey("MATCH_ALL_TRACKS_NOTE");
			MAXIMUM = getKey("MAXIMUM");
			MAX_IMAGE_CACHE_SIZE = getKey("MAX_IMAGE_CACHE_SIZE");
			MAX_VIDEO_CACHE_SIZE = getKey("MAX_VIDEO_CACHE_SIZE");
			METADATA_CACHE = getKey("METADATA_CACHE");
			METADATA_EDIT_FAILED = getKey("METADATA_EDIT_FAILED");
			METADATA_READ_FAILED = getKey("METADATA_READ_FAILED");
			MINIMUM_ONE_ITEM = getKey("MINIMUM_ONE_ITEM");
			MINIMUM_ONE_ITEM_SUBTITLE = getKey("MINIMUM_ONE_ITEM_SUBTITLE");
			MIN_FILE_DURATION_SUBTITLE = getKey("MIN_FILE_DURATION_SUBTITLE");
			MIN_FILE_DURATION = getKey("MIN_FILE_DURATION");
			MIN_FILE_SIZE_SUBTITLE = getKey("MIN_FILE_SIZE_SUBTITLE");
			MIN_FILE_SIZE = getKey("MIN_FILE_SIZE");
			MIN_TRACK_DURATION_TO_RESTORE_LAST_POSITION = getKey("MIN_TRACK_DURATION_TO_RESTORE_LAST_POSITION");
			MIN_VALUE_CANT_BE_MORE_THAN_MAX = getKey("MIN_VALUE_CANT_BE_MORE_THAN_MAX");
			MIN_VALUE_TO_COUNT_TRACK_LISTEN = getKey("MIN_VALUE_TO_COUNT_TRACK_LISTEN");
			MINIMUM_ONE_FOLDER_SUBTITLE = getKey("MINIMUM_ONE_FOLDER_SUBTITLE");
			MINIMUM = getKey("MINIMUM");
			MINIPLAYER_CUSTOMIZATION = getKey("MINIPLAYER_CUSTOMIZATION");
			MINUTES = getKey("MINUTES");
			MISSING_ENTRIES = getKey("MISSING_ENTRIES");
			MIXES = getKey("MIXES");
			MONTH = getKey("MONTH");
			MONTHS = getKey("MONTHS");
			MOODS = getKey("MOODS");
			MORE = getKey("MORE");
			MOST_PLAYED = getKey("MOST_PLAYED");
			MULTIPLE_TRACKS_TAGS_EDIT_NOTE = getKey("MULTIPLE_TRACKS_TAGS_EDIT_NOTE");
			NAME_CONTAINS_BAD_CHARACTER = getKey("NAME_CONTAINS_BAD_CHARACTER");
			NAME = getKey("NAME");
			NEW_DIRECTORY = getKey("NEW_DIRECTORY");
			NEW_TRACKS_ADD = getKey("NEW_TRACKS_ADD");
			NEW_TRACKS_MOODS_SUBTITLE = getKey("NEW_TRACKS_MOODS_SUBTITLE");
			NEW_TRACKS_MOODS = getKey("NEW_TRACKS_MOODS");
			NEW_TRACKS_RANDOM_SUBTITLE = getKey("NEW_TRACKS_RANDOM_SUBTITLE");
			NEW_TRACKS_RANDOM = getKey("NEW_TRACKS_RANDOM");
			NEW_TRACKS_RATINGS_SUBTITLE = getKey("NEW_TRACKS_RATINGS_SUBTITLE");
			NEW_TRACKS_RATINGS = getKey("NEW_TRACKS_RATINGS");
			NEW_TRACKS_RECOMMENDED_SUBTITLE = getKey("NEW_TRACKS_RECOMMENDED_SUBTITLE");
			NEW_TRACKS_RECOMMENDED = getKey("NEW_TRACKS_RECOMMENDED");
			NEW_TRACKS_SIMILARR_RELEASE_DATE_SUBTITLE = getKey("NEW_TRACKS_SIMILARR_RELEASE_DATE_SUBTITLE");
			NEW_TRACKS_SIMILARR_RELEASE_DATE = getKey("NEW_TRACKS_SIMILARR_RELEASE_DATE");
			NEW_TRACKS_UNKNOWN_YEAR = getKey("NEW_TRACKS_UNKNOWN_YEAR");
			NO_CHANGES_FOUND = getKey("NO_CHANGES_FOUND");
			NO_ENOUGH_TRACKS = getKey("NO_ENOUGH_TRACKS");
			NO_EXCLUDED_FOLDERS = getKey("NO_EXCLUDED_FOLDERS");
			NO_FOLDER_CHOSEN = getKey("NO_FOLDER_CHOSEN");
			NO_MOODS_AVAILABLE = getKey("NO_MOODS_AVAILABLE");
			NO_TRACKS_FOUND_BETWEEN_DATES = getKey("NO_TRACKS_FOUND_BETWEEN_DATES");
			NO_TRACKS_FOUND_IN_DIRECTORY = getKey("NO_TRACKS_FOUND_IN_DIRECTORY");
			NO_TRACKS_FOUND = getKey("NO_TRACKS_FOUND");
			NO_TRACKS_IN_HISTORY = getKey("NO_TRACKS_IN_HISTORY");
			NO = getKey("NO");
			NON_ACTIVE = getKey("NON_ACTIVE");
			NONE = getKey("NONE");
			NOTE = getKey("NOTE");
			NUMBER_OF_TRACKS = getKey("NUMBER_OF_TRACKS");
			OF = getKey("OF");
			OLDEST_WATCH = getKey("OLDEST_WATCH");
			OLD_DIRECTORY = getKey("OLD_DIRECTORY");
			OLD_DIRECTORY_STILL_HAS_TRACKS = getKey("OLD_DIRECTORY_STILL_HAS_TRACKS");
			ON_INTERRUPTION = getKey("ON_INTERRUPTION");
			ON_NOTIFICATION_TAP = getKey("ON_NOTIFICATION_TAP");
			ON_OPENING_YOUTUBE_LINK = getKey("ON_OPENING_YOUTUBE_LINK");
			ON_VOLUME_ZERO = getKey("ON_VOLUME_ZERO");
			OPEN_APP = getKey("OPEN_APP");
			OPEN_IN_YOUTUBE_VIEW = getKey("OPEN_IN_YOUTUBE_VIEW");
			OPEN_MINIPLAYER = getKey("OPEN_MINIPLAYER");
			OPEN_QUEUE = getKey("OPEN_QUEUE");
			OPEN_YOUTUBE_LINK = getKey("OPEN_YOUTUBE_LINK");
			OR = getKey("OR");
			OTHERS = getKey("OTHERS");
			OUTPUT = getKey("OUTPUT");
			PALETTE = getKey("PALETTE");
			PALETTE_MIX = getKey("PALETTE_MIX");
			PALETTE_NEW_MIX = getKey("PALETTE_NEW_MIX");
			PALETTE_SELECTED_MIX = getKey("PALETTE_SELECTED_MIX");
			PARSED = getKey("PARSED");
			PATH = getKey("PATH");
			PAUSE_FADE_DURATION = getKey("PAUSE_FADE_DURATION");
			PAUSE_PLAYBACK = getKey("PAUSE_PLAYBACK");
			PERCENTAGE = getKey("PERCENTAGE");
			PERFORMANCE_NOTE = getKey("PERFORMANCE_NOTE");
			PERMISSION_UPDATE = getKey("PERMISSION_UPDATE");
			PICK_COLORS_FROM_DEVICE_WALLPAPER = getKey("PICK_COLORS_FROM_DEVICE_WALLPAPER");
			PICK_FROM_STORAGE = getKey("PICK_FROM_STORAGE");
			PINNED = getKey("PINNED");
			PITCH = getKey("PITCH");
			PLAY_AFTER_NEXT_PREV = getKey("PLAY_AFTER_NEXT_PREV");
			PLAY_AFTER = getKey("PLAY_AFTER");
			PLAY_ALL = getKey("PLAY_ALL");
			PLAY_FADE_DURATION = getKey("PLAY_FADE_DURATION");
			PLAY_LAST = getKey("PLAY_LAST");
			PLAY_NEXT = getKey("PLAY_NEXT");
			PLAY = getKey("PLAY");
			PLAYBACK_SETTING_SUBTITLE = getKey("PLAYBACK_SETTING_SUBTITLE");
			PLAYBACK_SETTING = getKey("PLAYBACK_SETTING");
			PLAYLIST = getKey("PLAYLIST");
			PLAYLISTS = getKey("PLAYLISTS");
			PLEASE_ENTER_A_DIFFERENT_NAME = getKey("PLEASE_ENTER_A_DIFFERENT_NAME");
			PLEASE_ENTER_A_LINK_SUBTITLE = getKey("PLEASE_ENTER_A_LINK_SUBTITLE");
			PLEASE_ENTER_A_LINK = getKey("PLEASE_ENTER_A_LINK");
			PLEASE_ENTER_A_NAME = getKey("PLEASE_ENTER_A_NAME");
			PREVENT_DUPLICATED_TRACKS_SUBTITLE = getKey("PREVENT_DUPLICATED_TRACKS_SUBTITLE");
			PREVENT_DUPLICATED_TRACKS = getKey("PREVENT_DUPLICATED_TRACKS");
			PREVIEW = getKey("PREVIEW");
			PROGRESS = getKey("PROGRESS");
			PROMPT_INDEXING_REFRESH = getKey("PROMPT_INDEXING_REFRESH");
			PROMPT_TO_CHANGE_TRACK_PATH = getKey("PROMPT_TO_CHANGE_TRACK_PATH");
			QUEUE = getKey("QUEUE");
			QUEUES = getKey("QUEUES");
			RANDOM = getKey("RANDOM");
			RANDOM_PICKS = getKey("RANDOM_PICKS");
			RATING = getKey("RATING");
			RECENTLY_ADDED = getKey("RECENTLY_ADDED");
			RECENT_ALBUMS = getKey("RECENT_ALBUMS");
			RECENT_ARTISTS = getKey("RECENT_ARTISTS");
			RECENT_LISTENS = getKey("RECENT_LISTENS");
			REPLACE_ALL_LISTENS_WITH_ANOTHER_TRACK = getKey("REPLACE_ALL_LISTENS_WITH_ANOTHER_TRACK");
			RE_INDEX_SUBTITLE = getKey("RE_INDEX_SUBTITLE");
			RE_INDEX_WARNING = getKey("RE_INDEX_WARNING");
			RE_INDEX = getKey("RE_INDEX");
			RECORD_LABEL = getKey("RECORD_LABEL");
			REFRESH_LIBRARY_SUBTITLE = getKey("REFRESH_LIBRARY_SUBTITLE");
			REFRESH_LIBRARY = getKey("REFRESH_LIBRARY");
			REFRESH = getKey("REFRESH");
			REMIXER = getKey("REMIXER");
			REMOVE_DUPLICATES = getKey("REMOVE_DUPLICATES");
			REMOVE_FROM_PLAYLIST = getKey("REMOVE_FROM_PLAYLIST");
			REMOVE_QUEUE = getKey("REMOVE_QUEUE");
			REMOVE_SOURCE_FROM_HISTORY = getKey("REMOVE_SOURCE_FROM_HISTORY");
			REMOVE_WHITESPACES = getKey("REMOVE_WHITESPACES");
			REMOVE = getKey("REMOVE");
			REMOVED = getKey("REMOVED");
			RENAME_PLAYLIST = getKey("RENAME_PLAYLIST");
			REORDERABLE = getKey("REORDERABLE");
			REPEAT_FOR_N_TIMES = getKey("REPEAT_FOR_N_TIMES");
			REPEAT_MODE_ALL = getKey("REPEAT_MODE_ALL");
			REPEAT_MODE_NONE = getKey("REPEAT_MODE_NONE");
			REPEAT_MODE_ONE = getKey("REPEAT_MODE_ONE");
			REPLIES = getKey("REPLIES");
			REQUIRES_CLEARING_IMAGE_CACHE_AND_RE_INDEXING = getKey("REQUIRES_CLEARING_IMAGE_CACHE_AND_RE_INDEXING");
			RESCAN_VIDEOS = getKey("RESCAN_VIDEOS");
			RESET_TO_DEFAULT = getKey("RESET_TO_DEFAULT");
			RESPECT_NO_MEDIA_SUBTITLE = getKey("RESPECT_NO_MEDIA_SUBTITLE");
			RESPECT_NO_MEDIA = getKey("RESPECT_NO_MEDIA");
			RESTORE_BACKUP = getKey("RESTORE_BACKUP");
			RESTORE_DEFAULTS = getKey("RESTORE_DEFAULTS");
			RESTORED_BACKUP_SUCCESSFULLY_SUB = getKey("RESTORED_BACKUP_SUCCESSFULLY_SUB");
			RESTORED_BACKUP_SUCCESSFULLY = getKey("RESTORED_BACKUP_SUCCESSFULLY");
			RESUME_IF_WAS_INTERRUPTED = getKey("RESUME_IF_WAS_INTERRUPTED");
			RESUME_IF_WAS_PAUSED_BY_VOLUME = getKey("RESUME_IF_WAS_PAUSED_BY_VOLUME");
			REVERSE_ORDER = getKey("REVERSE_ORDER");
			SAME_DIRECTORY_ONLY = getKey("SAME_DIRECTORY_ONLY");
			SAMPLE_RATE = getKey("SAMPLE_RATE");
			SAVE = getKey("SAVE");
			SAVED_IN = getKey("SAVED_IN");
			SEARCH = getKey("SEARCH");
			SEARCH_YOUTUBE = getKey("SEARCH_YOUTUBE");
			SECONDS = getKey("SECONDS");
			SEEK_DURATION_INFO = getKey("SEEK_DURATION_INFO");
			SEEK_DURATION = getKey("SEEK_DURATION");
			SELECT_ALL = getKey("SELECT_ALL");
			SELECTED_TRACKS = getKey("SELECTED_TRACKS");
			SEPARATORS_BLACKLIST_SUBTITLE = getKey("SEPARATORS_BLACKLIST_SUBTITLE");
			SEPARATORS_MESSAGE = getKey("SEPARATORS_MESSAGE");
			SET_AS_DEFAULT = getKey("SET_AS_DEFAULT");
			SET_FILE_LAST_MODIFIED_AS_VIDEO_UPLOAD_DATE = getKey("SET_FILE_LAST_MODIFIED_AS_VIDEO_UPLOAD_DATE");
			SET_MOODS_SUBTITLE = getKey("SET_MOODS_SUBTITLE");
			SET_MOODS = getKey("SET_MOODS");
			SET_RATING = getKey("SET_RATING");
			SET_TAGS = getKey("SET_TAGS");
			SET_YOUTUBE_LINK = getKey("SET_YOUTUBE_LINK");
			SETTINGS = getKey("SETTINGS");
			SHARE = getKey("SHARE");
			SHOULD_DUCK = getKey("SHOULD_DUCK");
			SHOULD_DUCK_NOTE = getKey("SHOULD_DUCK_NOTE");
			SHOULD_PAUSE = getKey("SHOULD_PAUSE");
			SHOULD_PAUSE_NOTE = getKey("SHOULD_PAUSE_NOTE");
			SHOW_HIDE_UNKNOWN_FIELDS = getKey("SHOW_HIDE_UNKNOWN_FIELDS");
			SHOW_MORE = getKey("SHOW_MORE");
			SHOW_WEBM = getKey("SHOW_WEBM");
			SHUFFLE = getKey("SHUFFLE");
			SHUFFLE_ALL = getKey("SHUFFLE_ALL");
			SHUFFLE_NEXT = getKey("SHUFFLE_NEXT");
			SIZE = getKey("SIZE");
			SKIP_SILENCE = getKey("SKIP_SILENCE");
			SKIP = getKey("SKIP");
			SLEEP_AFTER = getKey("SLEEP_AFTER");
			SLEEP_TIMER = getKey("SLEEP_TIMER");
			SORT_BY = getKey("SORT_BY");
			SOURCE = getKey("SOURCE");
			SPEED = getKey("SPEED");
			STAGGERED_ALBUM_GRID_VIEW = getKey("STAGGERED_ALBUM_GRID_VIEW");
			START = getKey("START");
			STATS_SUBTITLE = getKey("STATS_SUBTITLE");
			STATS = getKey("STATS");
			STOP_AFTER_THIS_TRACK = getKey("STOP_AFTER_THIS_TRACK");
			STOP = getKey("STOP");
			STORAGE_PERMISSION_DENIED_SUBTITLE = getKey("STORAGE_PERMISSION_DENIED_SUBTITLE");
			STORAGE_PERMISSION_DENIED = getKey("STORAGE_PERMISSION_DENIED");
			SUBSCRIBE = getKey("SUBSCRIBE");
			SUBSCRIBED = getKey("SUBSCRIBED");
			SUBSCRIBER = getKey("SUBSCRIBER");
			SUBSCRIBERS = getKey("SUBSCRIBERS");
			SUCCEEDED = getKey("SUCCEEDED");
			SUPPORT = getKey("SUPPORT");
			SUPREMACY = getKey("SUPREMACY");
			SUSSY_BAKA = getKey("SUSSY_BAKA");
			SYNOPSIS = getKey("SYNOPSIS");
			TAG_FIELDS = getKey("TAG_FIELDS");
			TAGS = getKey("TAGS");
			THEME_MODE_DARK = getKey("THEME_MODE_DARK");
			THEME_MODE_LIGHT = getKey("THEME_MODE_LIGHT");
			THEME_MODE_SYSTEM = getKey("THEME_MODE_SYSTEM");
			THEME_MODE = getKey("THEME_MODE");
			THEME_SETTINGS_SUBTITLE = getKey("THEME_SETTINGS_SUBTITLE");
			THEME_SETTINGS = getKey("THEME_SETTINGS");
			THUMBNAILS = getKey("THUMBNAILS");
			TITLE = getKey("TITLE");
			TOP_RECENTS = getKey("TOP_RECENTS");
			TOP_RECENT_ALBUMS = getKey("TOP_RECENT_ALBUMS");
			TOP_RECENT_ARTISTS = getKey("TOP_RECENT_ARTISTS");
			TOTAL_LISTEN_TIME = getKey("TOTAL_LISTEN_TIME");
			TOTAL_LISTENS = getKey("TOTAL_LISTENS");
			TOTAL_TRACKS_DURATION = getKey("TOTAL_TRACKS_DURATION");
			TOTAL_TRACKS = getKey("TOTAL_TRACKS");
			TRACK_ARTISTS_SEPARATOR = getKey("TRACK_ARTISTS_SEPARATOR");
			TRACK_GENRES_SEPARATOR = getKey("TRACK_GENRES_SEPARATOR");
			TRACK_INFO = getKey("TRACK_INFO");
			TRACK_NOT_FOUND = getKey("TRACK_NOT_FOUND");
			TRACK_NUMBER_TOTAL = getKey("TRACK_NUMBER_TOTAL");
			TRACK_NUMBER = getKey("TRACK_NUMBER");
			TRACK_PATH_OLD_NEW = getKey("TRACK_PATH_OLD_NEW");
			TRACK_PLAY_MODE_SEARCH_RESULTS = getKey("TRACK_PLAY_MODE_SEARCH_RESULTS");
			TRACK_PLAY_MODE_SELECTED_ONLY = getKey("TRACK_PLAY_MODE_SELECTED_ONLY");
			TRACK_PLAY_MODE_TRACK_ALBUM = getKey("TRACK_PLAY_MODE_TRACK_ALBUM");
			TRACK_PLAY_MODE_TRACK_ARTIST = getKey("TRACK_PLAY_MODE_TRACK_ARTIST");
			TRACK_PLAY_MODE_TRACK_GENRE = getKey("TRACK_PLAY_MODE_TRACK_GENRE");
			TRACK_PLAY_MODE = getKey("TRACK_PLAY_MODE");
			TRACK_THUMBNAIL_SIZE_IN_LIST = getKey("TRACK_THUMBNAIL_SIZE_IN_LIST");
			TRACK_TILE_CUSTOMIZATION = getKey("TRACK_TILE_CUSTOMIZATION");
			TRACK_TILE_ITEMS_SEPARATOR = getKey("TRACK_TILE_ITEMS_SEPARATOR");
			TRACK = getKey("TRACK");
			TRACKS_EXCLUDED_BY_NOMEDIA = getKey("TRACKS_EXCLUDED_BY_NOMEDIA");
			TRACKS_INFO = getKey("TRACKS_INFO");
			TRACKS = getKey("TRACKS");
			UNDO_CHANGES_DELETED_PLAYLIST = getKey("UNDO_CHANGES_DELETED_PLAYLIST");
			UNDO_CHANGES_DELETED_QUEUE = getKey("UNDO_CHANGES_DELETED_QUEUE");
			UNDO_CHANGES_DELETED_TRACK = getKey("UNDO_CHANGES_DELETED_TRACK");
			UNDO_CHANGES = getKey("UNDO_CHANGES");
			UNDO = getKey("UNDO");
			UNLIMITED = getKey("UNLIMITED");
			UNLOCK = getKey("UNLOCK");
			UPDATE = getKey("UPDATE");
			UPDATE_DIRECTORY_PATH = getKey("UPDATE_DIRECTORY_PATH");
			UPDATE_MISSING_TRACKS_ONLY = getKey("UPDATE_MISSING_TRACKS_ONLY");
			UPDATING = getKey("UPDATING");
			USED = getKey("USED");
			USE_COLLAPSED_SETTING_TILES = getKey("USE_COLLAPSED_SETTING_TILES");
			VALUE_BETWEEN_50_200 = getKey("VALUE_BETWEEN_50_200");
			VALUE = getKey("VALUE");
			VIDEOS = getKey("VIDEOS");
			VIDEO_CACHE_FILE = getKey("VIDEO_CACHE_FILE");
			VIDEO_CACHE_FILES = getKey("VIDEO_CACHE_FILES");
			VIDEO_CACHE = getKey("VIDEO_CACHE");
			VIDEO_ONLY = getKey("VIDEO_ONLY");
			VIDEO_PLAYBACK_SOURCE_AUTO_SUBTITLE = getKey("VIDEO_PLAYBACK_SOURCE_AUTO_SUBTITLE");
			VIDEO_PLAYBACK_SOURCE_LOCAL_EXAMPLE_SUBTITLE = getKey("VIDEO_PLAYBACK_SOURCE_LOCAL_EXAMPLE_SUBTITLE");
			VIDEO_PLAYBACK_SOURCE_LOCAL_EXAMPLE = getKey("VIDEO_PLAYBACK_SOURCE_LOCAL_EXAMPLE");
			VIDEO_PLAYBACK_SOURCE_LOCAL_SUBTITLE = getKey("VIDEO_PLAYBACK_SOURCE_LOCAL_SUBTITLE");
			VIDEO_PLAYBACK_SOURCE_LOCAL = getKey("VIDEO_PLAYBACK_SOURCE_LOCAL");
			VIDEO_PLAYBACK_SOURCE_YOUTUBE_SUBTITLE = getKey("VIDEO_PLAYBACK_SOURCE_YOUTUBE_SUBTITLE");
			VIDEO_PLAYBACK_SOURCE_YOUTUBE = getKey("VIDEO_PLAYBACK_SOURCE_YOUTUBE");
			VIDEO_PLAYBACK_SOURCE = getKey("VIDEO_PLAYBACK_SOURCE");
			VIDEO_QUALITY_SUBTITLE_NOTE = getKey("VIDEO_QUALITY_SUBTITLE_NOTE");
			VIDEO_QUALITY_SUBTITLE = getKey("VIDEO_QUALITY_SUBTITLE");
			VIDEO_QUALITY = getKey("VIDEO_QUALITY");
			VIDEO = getKey("VIDEO");
			VIEW_ALL = getKey("VIEW_ALL");
			VOLUME = getKey("VOLUME");
			WARNING = getKey("WARNING");
			WAVEFORM_BARS_COUNT = getKey("WAVEFORM_BARS_COUNT");
			WAVEFORMS = getKey("WAVEFORMS");
			WEBM_NO_EDIT_TAGS_SUPPORT = getKey("WEBM_NO_EDIT_TAGS_SUPPORT");
			WEEK = getKey("WEEK");
			YEAR = getKey("YEAR");
			YES = getKey("YES");
			YOUTUBE_MUSIC = getKey("YOUTUBE_MUSIC");
			YOUTUBE = getKey("YOUTUBE");
			YOUTUBE_SETTINGS_SUBTITLE = getKey("YOUTUBE_SETTINGS_SUBTITLE");
			YT_PREFER_NEW_COMMENTS = getKey("YT_PREFER_NEW_COMMENTS");
			YT_PREFER_NEW_COMMENTS_SUBTITLE = getKey("YT_PREFER_NEW_COMMENTS_SUBTITLE");
			// -- Keys End ---------------------------------------------------------

      _currentLanguage.value = lang;
      settings.save(selectedLanguage: lang);
      lang.refreshConverterMaps();

      return true;
    } catch (e) {
      printy(e, isError: true);
      return false;
    }
  }
}













































