import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:namida/controller/indexer_controller.dart';

class ScrollSearchController extends GetxController {
  static final ScrollSearchController inst = ScrollSearchController();

  RxBool isGlobalSearchMenuShown = false.obs;

  RxBool showTrackSearchBox = false.obs;
  RxBool showAlbumSearchBox = false.obs;
  RxBool showArtistSearchBox = false.obs;
  RxBool showGenreSearchBox = false.obs;

  Rx<ScrollController> trackScrollcontroller = ScrollController().obs;
  Rx<ScrollController> albumScrollcontroller = ScrollController().obs;
  Rx<ScrollController> artistScrollcontroller = ScrollController().obs;
  Rx<ScrollController> genreScrollcontroller = ScrollController().obs;

  RxBool isTrackBarVisible = true.obs;
  RxBool isAlbumBarVisible = true.obs;
  RxBool isArtistBarVisible = true.obs;
  RxBool isGenreBarVisible = true.obs;

  ScrollSearchController() {
    trackScrollcontroller.value.addListener(() {
      if (trackScrollcontroller.value.position.userScrollDirection == ScrollDirection.reverse) {
        isTrackBarVisible.value = false;
      }
      if (trackScrollcontroller.value.position.userScrollDirection == ScrollDirection.forward) {
        isTrackBarVisible.value = true;
      }
    });

    albumScrollcontroller.value.addListener(() {
      if (albumScrollcontroller.value.position.userScrollDirection == ScrollDirection.reverse) {
        isAlbumBarVisible.value = false;
      }
      if (albumScrollcontroller.value.position.userScrollDirection == ScrollDirection.forward) {
        isAlbumBarVisible.value = true;
      }
    });
    artistScrollcontroller.value.addListener(() {
      if (artistScrollcontroller.value.position.userScrollDirection == ScrollDirection.reverse) {
        isArtistBarVisible.value = false;
      }
      if (artistScrollcontroller.value.position.userScrollDirection == ScrollDirection.forward) {
        isArtistBarVisible.value = true;
      }
    });
    genreScrollcontroller.value.addListener(() {
      if (genreScrollcontroller.value.position.userScrollDirection == ScrollDirection.reverse) {
        isGenreBarVisible.value = false;
      }
      if (genreScrollcontroller.value.position.userScrollDirection == ScrollDirection.forward) {
        isGenreBarVisible.value = true;
      }
    });
  }

  /// Tracks
  void switchTrackSearchBoxVisibilty({bool forceHide = false, bool forceShow = false}) {
    if (forceHide) {
      showTrackSearchBox.value = false;
      return;
    }
    if (forceShow) {
      showTrackSearchBox.value = true;
      return;
    }
    if (Indexer.inst.tracksSearchController.value.text == '') {
      showTrackSearchBox.value = !showTrackSearchBox.value;
    } else {
      showTrackSearchBox.value = true;
    }
  }

  void clearTrackSearchTextField() {
    Indexer.inst.searchTracks('');
    showTrackSearchBox.value = false;
  }

  /// Albums
  void switchAlbumSearchBoxVisibilty({bool forceHide = false, bool forceShow = false}) {
    if (forceHide) {
      showAlbumSearchBox.value = false;
      return;
    }
    if (forceShow) {
      showAlbumSearchBox.value = true;
      return;
    }
    if (Indexer.inst.albumsSearchController.value.text == '') {
      showAlbumSearchBox.value = !showAlbumSearchBox.value;
    } else {
      showAlbumSearchBox.value = true;
    }
  }

  void clearAlbumSearchTextField() {
    Indexer.inst.searchAlbums('');
    showAlbumSearchBox.value = false;
  }

  /// Artists
  void switchArtistSearchBoxVisibilty({bool forceHide = false, bool forceShow = false}) {
    if (forceHide) {
      showArtistSearchBox.value = false;
      return;
    }
    if (forceShow) {
      showArtistSearchBox.value = true;
      return;
    }
    if (Indexer.inst.artistsSearchController.value.text == '') {
      showArtistSearchBox.value = !showArtistSearchBox.value;
    } else {
      showArtistSearchBox.value = true;
    }
  }

  void clearArtistSearchTextField() {
    Indexer.inst.searchArtists('');
    showArtistSearchBox.value = false;
  }

  /// Genres
  void switchGenreSearchBoxVisibilty({bool forceHide = false, bool forceShow = false}) {
    if (forceHide) {
      showGenreSearchBox.value = false;
      return;
    }
    if (forceShow) {
      showGenreSearchBox.value = true;
      return;
    }
    if (Indexer.inst.genresSearchController.value.text == '') {
      showGenreSearchBox.value = !showGenreSearchBox.value;
    } else {
      showGenreSearchBox.value = true;
    }
  }

  void clearGenreSearchTextField() {
    Indexer.inst.searchGenres('');
    showGenreSearchBox.value = false;
  }
}