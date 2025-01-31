import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:get/get.dart';

import 'package:namida/class/video.dart';
import 'package:namida/controller/current_color.dart';
import 'package:namida/controller/navigator_controller.dart';
import 'package:namida/controller/player_controller.dart';
import 'package:namida/controller/settings_controller.dart';
import 'package:namida/controller/video_controller.dart';
import 'package:namida/youtube/controller/youtube_controller.dart';
import 'package:namida/core/extensions.dart';
import 'package:namida/core/icon_fonts/broken_icons.dart';
import 'package:namida/core/namida_converter_ext.dart';
import 'package:namida/core/translations/language.dart';
import 'package:namida/packages/tap_detector.dart';
import 'package:namida/packages/three_arched_circle.dart';
import 'package:namida/ui/widgets/custom_widgets.dart';

class NamidaVideoControls extends StatefulWidget {
  final Widget? child;
  final bool showControls;
  final VoidCallback? onMinimizeTap;
  final Widget? fallbackChild;
  final bool isFullScreen;
  final List<NamidaPopupItem> qualityItems;
  final GlobalKey<NamidaVideoControlsState> widgetKey;

  const NamidaVideoControls({
    super.key,
    required this.widgetKey,
    required this.child,
    required this.showControls,
    required this.onMinimizeTap,
    required this.fallbackChild,
    required this.isFullScreen,
    this.qualityItems = const [],
  });

  @override
  State<NamidaVideoControls> createState() => NamidaVideoControlsState();
}

class NamidaVideoControlsState extends State<NamidaVideoControls> with TickerProviderStateMixin {
  Widget _getSliderContainer(
    Color colorScheme,
    BoxConstraints constraints,
    double percentage,
    int alpha, {
    bool displayIndicator = false,
  }) {
    return Container(
      alignment: Alignment.centerRight,
      height: 5.0,
      width: constraints.maxWidth * percentage,
      decoration: BoxDecoration(
        color: Color.alphaBlend(Colors.white.withOpacity(0.3), colorScheme).withAlpha(alpha),
        borderRadius: BorderRadius.circular(6.0.multipliedRadius),
      ),
      child: displayIndicator
          ? Container(
              width: 4.0,
              height: 4.0,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }

  bool _isVisible = false;
  final hideDuration = const Duration(seconds: 3);
  final volumeHideDuration = const Duration(milliseconds: 500);
  final transitionDuration = const Duration(milliseconds: 300);
  final doubleTapSeekReset = const Duration(milliseconds: 600);

  Timer? _hideTimer;
  void _resetTimer({bool hideControls = false}) {
    _hideTimer?.cancel();
    _hideTimer = null;
    if (hideControls) setControlsVisibily(false);
  }

  void _startTimer() {
    _resetTimer();
    if (_isVisible) {
      _hideTimer = Timer(hideDuration, () {
        setControlsVisibily(false);
      });
    }
  }

  void setControlsVisibily(bool visible) {
    _isVisible = visible;
    if (mounted) setState(() {});
  }

  final userSeekMS = 0.obs;

  Widget _getBuilder({
    required Widget Function(double visiblePercentage) child,
  }) {
    return IgnorePointer(
      ignoring: !_isVisible,
      child: AnimatedOpacity(
        duration: transitionDuration,
        opacity: _isVisible ? 1.0 : 0.0,
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: transitionDuration,
          builder: (context, perc, _) => child(perc),
        ),
      ),
    );
  }

  void _onTap() {
    _currentDeviceVolume.value = null; // hide volume slider
    if (_shouldSeekOnTap) return;
    if (_isVisible) {
      setControlsVisibily(false);
    } else {
      if (widget.showControls) {
        setControlsVisibily(true);
      }
    }
    _startTimer();
  }

  bool _shouldSeekOnTap = false;
  Timer? _doubleSeekTimer;
  void _startSeekTimer(bool forward) {
    _shouldSeekOnTap = true;
    _doubleSeekTimer?.cancel();
    _doubleSeekTimer = Timer(doubleTapSeekReset, () {
      _shouldSeekOnTap = false;
      _seekSeconds = 0;
    });
  }

  int _seekSeconds = 0;

  /// This prevents mixing up forward seek seconds with backward ones.
  bool _lastSeekWasForward = true;

  void _onDoubleTap(Offset position) async {
    final totalWidth = context.width;
    final halfScreen = totalWidth / 2;
    final middleAmmountToIgnore = totalWidth / 6;
    final pos = position.dx - halfScreen;
    if (pos.abs() > middleAmmountToIgnore) {
      if (pos.isNegative) {
        // -- Seeking Backwards
        animateSeekControllers(false);
        _startSeekTimer(false);
        Player.inst.seekSecondsBackward(
          onSecondsReady: (finalSeconds) {
            if (_shouldSeekOnTap && !_lastSeekWasForward) {
              // only increase if not at the start
              if (Player.inst.nowPlayingPosition != 0) {
                _seekSeconds += finalSeconds;
              }
            } else {
              _seekSeconds = finalSeconds;
            }
          },
        );
        _lastSeekWasForward = false;
      } else {
        // -- Seeking Forwards
        animateSeekControllers(true);
        _startSeekTimer(true);
        Player.inst.seekSecondsForward(
          onSecondsReady: (finalSeconds) {
            if (_shouldSeekOnTap && _lastSeekWasForward) {
              // only increase if not at the end
              if (Player.inst.nowPlayingPosition != Player.inst.currentItemDuration?.inMilliseconds) {
                _seekSeconds += finalSeconds;
              }
            } else {
              _seekSeconds = finalSeconds;
            }
          },
        );
        _lastSeekWasForward = true;
      }
    }
  }

  void animateSeekControllers(bool isForward) async {
    if (isForward) {
      // -- first container
      _animateAfterDelayMS(controller: seekAnimationForward1, delay: 0, target: 1.0);
      _animateAfterDelayMS(controller: seekAnimationForward1, delay: 500, target: 0.0);

      // -- second container
      _animateAfterDelayMS(controller: seekAnimationForward2, delay: 200, target: 1.0);
      _animateAfterDelayMS(controller: seekAnimationForward2, delay: 600, target: 0.0);
    } else {
      // -- first container
      _animateAfterDelayMS(controller: seekAnimationBackward1, delay: 0, target: 1.0);
      _animateAfterDelayMS(controller: seekAnimationBackward1, delay: 500, target: 0.0);

      // -- second container
      _animateAfterDelayMS(controller: seekAnimationBackward2, delay: 200, target: 1.0);
      _animateAfterDelayMS(controller: seekAnimationBackward2, delay: 600, target: 0.0);
    }
  }

  Future<void> _animateAfterDelayMS({
    required AnimationController controller,
    required int delay,
    required double target,
  }) async {
    await Future.delayed(Duration(milliseconds: delay));
    await controller.animateTo(target);
  }

  @override
  void initState() {
    super.initState();
    const dur = Duration(milliseconds: 200);
    const dur2 = Duration(milliseconds: 200);
    seekAnimationForward1 = AnimationController(
      vsync: this,
      duration: dur,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    seekAnimationForward2 = AnimationController(
      vsync: this,
      duration: dur2,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    seekAnimationBackward1 = AnimationController(
      vsync: this,
      duration: dur,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    seekAnimationBackward2 = AnimationController(
      vsync: this,
      duration: dur2,
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    FlutterVolumeController.addListener(
      (value) async {
        if (widget.showControls) {
          final ast = await FlutterVolumeController.getAndroidAudioStream();
          if (ast == AudioStream.music) {
            _currentDeviceVolume.value = value;
          }
        }
      },
      emitOnStart: false,
    );
  }

  @override
  void dispose() {
    seekAnimationForward1.dispose();
    seekAnimationForward2.dispose();
    seekAnimationBackward1.dispose();
    seekAnimationBackward2.dispose();
    FlutterVolumeController.removeListener();
    super.dispose();
  }

  late AnimationController seekAnimationForward1;
  late AnimationController seekAnimationForward2;
  late AnimationController seekAnimationBackward1;
  late AnimationController seekAnimationBackward2;

  Widget _getSeekAnimatedContainer({
    required AnimationController controller,
    required bool isForward,
    required bool isSecondary,
  }) {
    final seekContainerSize = context.width;
    final offsetPercentage = isSecondary ? 0.7 : 0.55;
    final finalOffset = -(seekContainerSize * offsetPercentage);
    return Positioned(
      right: isForward ? finalOffset : null,
      left: isForward ? null : finalOffset,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Opacity(
              opacity: controller.value,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                width: seekContainerSize,
                height: seekContainerSize,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget getSeekTextWidget({
    required AnimationController controller,
    required bool isForward,
  }) {
    final seekContainerSize = context.width;
    final finalOffset = seekContainerSize * 0.05;
    final color = Colors.black.withOpacity(0.8);
    final forwardIcons = <int, IconData>{
      5: Broken.forward_5_seconds,
      10: Broken.forward_10_seconds,
      15: Broken.forward_15_seconds,
    };
    final backwardIcons = <int, IconData>{
      5: Broken.backward_5_seconds,
      10: Broken.backward_10_seconds,
      15: Broken.backward_15_seconds,
    };
    return Positioned(
      right: isForward ? finalOffset : null,
      left: isForward ? null : finalOffset,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final ss = _seekSeconds;
            return Opacity(
              opacity: controller.value,
              child: Column(
                children: [
                  Icon(
                    isForward ? forwardIcons[ss] ?? Broken.forward : backwardIcons[ss] ?? Broken.backward,
                    color: color,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '$ss ${lang.SECONDS}',
                    style: context.textTheme.displayMedium?.copyWith(color: color),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _getQualityChip({
    required String title,
    String subtitle = '',
    IconData? icon,
    required void Function(bool isSelected) onPlay,
    required bool selected,
    required bool isCached,
  }) {
    return NamidaInkWell(
      onTap: () {
        _startTimer();
        Navigator.of(context).pop();
        onPlay(selected);
      },
      decoration: const BoxDecoration(),
      borderRadius: 6.0,
      bgColor: selected ? CurrentColor.inst.color.withAlpha(100) : null,
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      padding: const EdgeInsets.all(6.0),
      child: Row(
        children: [
          Icon(icon ?? (isCached ? Broken.tick_circle : Broken.story), size: 20.0),
          const SizedBox(width: 4.0),
          Text(
            title,
            style: context.textTheme.displayMedium?.copyWith(fontSize: 13.0.multipliedFontScale),
          ),
          if (subtitle != '')
            Text(
              subtitle,
              style: context.textTheme.displaySmall?.copyWith(fontSize: 12.0.multipliedFontScale),
            ),
        ],
      ),
    );
  }

  double _volumeThreshold = 0.0;
  final _volumeMinDistance = 10.0;
  final _currentDeviceVolume = Rxn<double>();

  Timer? _volumeSwipeTimer;
  void _startVolumeSwipeTimer() {
    _volumeSwipeTimer?.cancel();
    _volumeSwipeTimer = Timer(volumeHideDuration, () {
      _currentDeviceVolume.value = null;
    });
  }

  bool _canSlideVolume(BuildContext context, double globalHeight) {
    final minimumVerticalDistanceToIgnoreSwipes = context.height * 0.1;

    final isSafeFromDown = globalHeight > minimumVerticalDistanceToIgnoreSwipes;
    final isSafeFromUp = globalHeight < context.height - minimumVerticalDistanceToIgnoreSwipes;
    return isSafeFromDown && isSafeFromUp;
  }

  bool _disableSliderVolume = false;

  @override
  Widget build(BuildContext context) {
    final dummyWidget = widget.fallbackChild ??
        Container(
          key: const Key('dummy_container'),
          color: Colors.transparent,
        );
    final horizontalControlsPadding =
        widget.isFullScreen ? const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0) : const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0);
    final itemsColor = Colors.white.withAlpha(200);
    final shouldShowVolumeSlider = widget.showControls && widget.isFullScreen;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerCancel: (event) {
        _disableSliderVolume = false;
        if (shouldShowVolumeSlider) {
          _startVolumeSwipeTimer();
        }
      },
      onPointerUp: (event) {
        _disableSliderVolume = false;
        if (shouldShowVolumeSlider) {
          _startVolumeSwipeTimer();
        }
      },
      onPointerDown: (event) {
        if (_shouldSeekOnTap) {
          _onDoubleTap(event.position);
          _startTimer();
        }
        _disableSliderVolume = !_canSlideVolume(context, event.position.dy);
      },
      onPointerMove: !shouldShowVolumeSlider
          ? null
          : (event) async {
              if (_disableSliderVolume) return;
              final d = event.delta.dy;
              _volumeThreshold += d;
              if (_volumeThreshold >= _volumeMinDistance) {
                _volumeThreshold = 0.0;
                await FlutterVolumeController.lowerVolume(null);
              } else if (_volumeThreshold <= -_volumeMinDistance) {
                _volumeThreshold = 0.0;
                await FlutterVolumeController.raiseVolume(null);
              }
            },
      child: TapDetector(
        enableTaps: widget.showControls,
        onTap: (d) => _onTap(),
        onDoubleTap: (details) => _onDoubleTap(details.localPosition),
        doubleTapTime: const Duration(milliseconds: 200),
        child: Stack(
          fit: StackFit.passthrough,
          alignment: Alignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Obx(
                  () => VideoController.vcontroller.isInitialized
                      ? NamidaAspectRatio(
                          aspectRatio: VideoController.vcontroller.aspectRatio,
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 200),
                            scale: 1.0 + VideoController.inst.videoZoomAdditionalScale.value * 0.02,
                            child: widget.child ?? dummyWidget,
                          ),
                        )
                      : SizedBox(
                          height: context.height,
                          width: context.height * 16 / 9,
                          child: dummyWidget,
                        ),
                ),
              ],
            ),
            if (widget.showControls) ...[
              // ---- Top Row ----
              Padding(
                padding: horizontalControlsPadding,
                child: GestureDetector(
                  onTap: () {},
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: _getBuilder(
                      child: (visiblePercentage) {
                        return Row(
                          children: [
                            if (widget.isFullScreen || widget.onMinimizeTap != null)
                              NamidaIconButton(
                                horizontalPadding: 12.0,
                                verticalPadding: 6.0,
                                onPressed: widget.isFullScreen ? NamidaNavigator.inst.exitFullScreen : widget.onMinimizeTap,
                                icon: Broken.arrow_down_2,
                                iconColor: itemsColor,
                                iconSize: 20.0,
                              ),
                            const Spacer(),
                            // ===== Speed Chip =====
                            NamidaPopupWrapper(
                              onPop: _startTimer,
                              onTap: () {
                                _resetTimer();
                                setControlsVisibily(true);
                              },
                              children: [
                                ...[0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map((speed) {
                                  return Obx(
                                    () {
                                      final isSelected = Player.inst.currentSpeed == speed;
                                      return NamidaInkWell(
                                        onTap: () {
                                          _startTimer();
                                          Navigator.of(context).pop();
                                          if (!isSelected) {
                                            Player.inst.setPlayerSpeed(speed);
                                          }
                                        },
                                        decoration: const BoxDecoration(),
                                        borderRadius: 6.0,
                                        bgColor: isSelected ? CurrentColor.inst.color.withAlpha(100) : null,
                                        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                        padding: const EdgeInsets.all(6.0),
                                        child: Row(
                                          children: [
                                            const Icon(Broken.play_cricle, size: 20.0),
                                            const SizedBox(width: 12.0),
                                            Text(
                                              "$speed",
                                              style: context.textTheme.displayMedium?.copyWith(fontSize: 13.0.multipliedFontScale),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ],
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6.0.multipliedRadius),
                                  child: NamidaBgBlur(
                                    blur: visiblePercentage * 3.0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.2 * visiblePercentage),
                                        borderRadius: BorderRadius.circular(6.0.multipliedRadius),
                                      ),
                                      child: Obx(
                                        () => Row(
                                          children: [
                                            Icon(
                                              Broken.play_cricle,
                                              size: 20.0,
                                              color: itemsColor,
                                            ),
                                            const SizedBox(width: 4.0).animateEntrance(showWhen: Player.inst.currentSpeed != 1.0, allCurves: Curves.easeInOutQuart),
                                            Text(
                                              "${Player.inst.currentSpeed}",
                                              style: context.textTheme.displaySmall?.copyWith(
                                                color: itemsColor,
                                                fontSize: 12.0,
                                              ),
                                            ).animateEntrance(showWhen: Player.inst.currentSpeed != 1.0, allCurves: Curves.easeInOutQuart),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // ===== Quality Chip =====
                            Obx(
                              () {
                                final ytQualities = YoutubeController.inst.currentYTQualities.where((s) => s.formatSuffix != 'webm');
                                final cachedQualitiesAll = YoutubeController.inst.currentCachedQualities;
                                final cachedQualities = List<NamidaVideo>.from(cachedQualitiesAll);
                                cachedQualities.removeWhere(
                                  (cq) {
                                    return ytQualities.any((ytq) {
                                      final c1 = ytq.resolution?.startsWith(cq.height.toString()) ?? false;
                                      final c2 = ytq.sizeInBytes == cq.sizeInBytes;
                                      final isSame = c1 && c2;
                                      return isSame;
                                    });
                                  },
                                );
                                return NamidaPopupWrapper(
                                  openOnTap: true,
                                  onPop: _startTimer,
                                  onTap: () {
                                    _resetTimer();
                                    setControlsVisibily(true);
                                  },
                                  childrenDefault: widget.qualityItems,
                                  children: [
                                    _getQualityChip(
                                      title: lang.AUDIO_ONLY,
                                      onPlay: (isSelected) {
                                        Player.inst.setAudioOnlyPlayback(true);
                                      },
                                      selected: Player.inst.isAudioOnlyPlayback,
                                      isCached: false,
                                      icon: Broken.musicnote,
                                    ),
                                    ...cachedQualities.map(
                                      (element) => Obx(
                                        () => _getQualityChip(
                                          title: '${element.height}p${element.framerateText()}',
                                          subtitle: " • ${element.sizeInBytes.fileSizeFormatted}",
                                          onPlay: (isSelected) {
                                            if (!isSelected) {
                                              Player.inst.onItemPlayYoutubeIDSetQuality(
                                                stream: null,
                                                cachedFile: File(element.path),
                                                videoItem: element,
                                                useCache: true,
                                                videoId: Player.inst.nowPlayingVideoID?.id ?? '',
                                              );
                                            }
                                          },
                                          selected: Player.inst.currentCachedVideo?.path == element.path,
                                          isCached: true,
                                        ),
                                      ),
                                    ),
                                    ...ytQualities.map((element) {
                                      return Obx(
                                        () {
                                          final isSelected = element.resolution == Player.inst.currentVideoStream?.resolution;
                                          final id = Player.inst.nowPlayingVideoID?.id;
                                          final cachedFile = id == null ? null : element.getCachedFile(id);
                                          return _getQualityChip(
                                            title: element.resolution ?? '',
                                            subtitle: " • ${element.sizeInBytes?.fileSizeFormatted ?? ''}",
                                            onPlay: (isSelected) {
                                              if (!isSelected) {
                                                Player.inst.onItemPlayYoutubeIDSetQuality(
                                                  stream: element,
                                                  cachedFile: cachedFile,
                                                  useCache: true,
                                                  videoId: id ?? '',
                                                );
                                              }
                                            },
                                            selected: isSelected,
                                            isCached: cachedFile != null,
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ],
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6.0.multipliedRadius),
                                      child: NamidaBgBlur(
                                        blur: visiblePercentage * 3.0,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.2 * visiblePercentage),
                                            borderRadius: BorderRadius.circular(6.0.multipliedRadius),
                                          ),
                                          child: Obx(
                                            () {
                                              final qts = Player.inst.currentVideoStream?.resolution;
                                              final c = Player.inst.currentCachedVideo;
                                              final qtc = c == null ? null : '${c.height}p${c.framerateText()}';
                                              final qt = qts ?? qtc;
                                              return Row(
                                                children: [
                                                  if (qt != null) ...[
                                                    Text(
                                                      qt,
                                                      style: context.textTheme.displaySmall?.copyWith(color: itemsColor),
                                                    ),
                                                    const SizedBox(width: 4.0),
                                                  ],
                                                  Icon(
                                                    Player.inst.isAudioOnlyPlayback ? Broken.musicnote : Broken.setting,
                                                    color: itemsColor,
                                                    size: 20.0,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              // ---- Bottom Row ----
              Padding(
                padding: horizontalControlsPadding,
                child: GestureDetector(
                  onTap: () {},
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _getBuilder(
                      child: (visiblePercentage) {
                        final borr = BorderRadius.circular(10.0.multipliedRadius);
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ClipRRect(
                            borderRadius: borr,
                            child: NamidaBgBlur(
                              blur: visiblePercentage * 3.0,
                              child: Container(
                                padding: const EdgeInsets.all(7.0),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2 * visiblePercentage),
                                  borderRadius: borr,
                                ),
                                child: Obx(
                                  () {
                                    final playerDuration = Player.inst.currentItemDuration ?? Duration.zero;
                                    final durMS = playerDuration.inMilliseconds;
                                    final videoBuffered = VideoController.vcontroller.buffered ?? Duration.zero;
                                    final audioBuffered = Player.inst.buffered;
                                    // display audio buffer only if audio < video
                                    final playerBufferedBigger = videoBuffered > audioBuffered ? videoBuffered : audioBuffered;
                                    final playerBufferedLower = videoBuffered > audioBuffered ? audioBuffered : videoBuffered;
                                    final currentPositionMS = Player.inst.nowPlayingPosition;
                                    // this for audio only mode
                                    final fullVideoBufferProgress = VideoController.vcontroller.isInitialized ? VideoController.vcontroller.isCurrentVideoFromCache : true;
                                    final currentVideoAudioFromCache = fullVideoBufferProgress && Player.inst.isCurrentAudioFromCache;
                                    final positionToDisplay = userSeekMS.value == 0 ? currentPositionMS : userSeekMS.value;
                                    final currentPercentage = durMS == 0.0 ? 0.0 : positionToDisplay / durMS;
                                    return Row(
                                      children: [
                                        Text(
                                          positionToDisplay.milliSecondsLabel,
                                          style: context.textTheme.displayMedium?.copyWith(
                                            fontSize: 14.0.multipliedFontScale,
                                            color: itemsColor,
                                          ),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              void onSeekDragUpdate(double deltax) {
                                                final percentageSwiped = (deltax / constraints.maxWidth).withMinimum(0.0);
                                                final newSeek = percentageSwiped * (playerDuration.inMilliseconds);
                                                userSeekMS.value = newSeek.round();
                                              }

                                              void onSeekEnd() async {
                                                await Player.inst.seek(Duration(milliseconds: userSeekMS.value));
                                                userSeekMS.value = 0;
                                              }

                                              return GestureDetector(
                                                behavior: HitTestBehavior.translucent,
                                                onTapDown: (details) {
                                                  onSeekDragUpdate(details.localPosition.dx);
                                                  _resetTimer();
                                                },
                                                onTapUp: (details) {
                                                  onSeekEnd();
                                                  _startTimer();
                                                },
                                                onTapCancel: () {
                                                  userSeekMS.value = 0;
                                                  _startTimer();
                                                },
                                                onHorizontalDragStart: (details) => _resetTimer(),
                                                onHorizontalDragUpdate: (details) => onSeekDragUpdate(details.localPosition.dx),
                                                onHorizontalDragEnd: (details) => onSeekEnd(),
                                                child: () {
                                                  const circleSize = 18.0;
                                                  final colorScheme = Color.alphaBlend(Colors.white.withAlpha(80), CurrentColor.inst.color.withOpacity(1));
                                                  return Stack(
                                                    alignment: Alignment.centerLeft,
                                                    children: [
                                                      _getSliderContainer(
                                                        colorScheme,
                                                        constraints,
                                                        currentPercentage,
                                                        160,
                                                      ),
                                                      // -- low buffer
                                                      if (currentVideoAudioFromCache || (playerBufferedLower > Duration.zero && durMS > 0))
                                                        _getSliderContainer(
                                                          colorScheme,
                                                          constraints,
                                                          currentVideoAudioFromCache ? 1.0 : playerBufferedLower.inMilliseconds / durMS,
                                                          80,
                                                          displayIndicator: true,
                                                        ),
                                                      // -- big buffer
                                                      if (currentVideoAudioFromCache || (playerBufferedBigger > Duration.zero && durMS > 0))
                                                        _getSliderContainer(
                                                          colorScheme,
                                                          constraints,
                                                          currentVideoAudioFromCache ? 1.0 : playerBufferedBigger.inMilliseconds / durMS,
                                                          60,
                                                          displayIndicator: true,
                                                        ),
                                                      _getSliderContainer(
                                                        colorScheme,
                                                        constraints,
                                                        1.0,
                                                        40,
                                                      ),
                                                      Container(
                                                        alignment: Alignment.center,
                                                        margin:
                                                            EdgeInsets.only(left: ((constraints.maxWidth * currentPercentage) - circleSize * 0.5).clamp(0, constraints.maxWidth)),
                                                        decoration: BoxDecoration(
                                                          color: colorScheme,
                                                          shape: BoxShape.circle,
                                                        ),
                                                        width: circleSize,
                                                        height: circleSize,
                                                        child: Container(
                                                          alignment: Alignment.center,
                                                          decoration: const BoxDecoration(
                                                            color: Color.fromARGB(220, 40, 40, 40),
                                                            shape: BoxShape.circle,
                                                          ),
                                                          width: circleSize / 2,
                                                          height: circleSize / 2,
                                                        ),
                                                      )
                                                    ],
                                                  );
                                                }(),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Obx(
                                          () {
                                            final displayRemaining = settings.displayRemainingDurInsteadOfTotal.value;
                                            final toSubtract = displayRemaining ? currentPositionMS : 0;
                                            final msToDisplay = playerDuration.inMilliseconds - toSubtract;
                                            final prefix = displayRemaining ? '-' : '';

                                            return Text(
                                              "$prefix ${msToDisplay.milliSecondsLabel}",
                                              style: context.textTheme.displayMedium?.copyWith(
                                                fontSize: 14.0.multipliedFontScale,
                                                color: itemsColor,
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 8.0),
                                        NamidaIconButton(
                                          horizontalPadding: 0.0,
                                          padding: EdgeInsets.zero,
                                          iconSize: 18.0,
                                          icon: Broken.maximize_2,
                                          iconColor: itemsColor,
                                          onPressed: () {
                                            _startTimer();
                                            VideoController.inst.toggleFullScreenVideoView(fallbackChild: widget.fallbackChild);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // ---- Middle Actions ----
              _getBuilder(
                child: (visiblePercentage) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(),
                      Obx(
                        () {
                          final shouldShowPrev = Player.inst.currentIndex != 0;
                          return IgnorePointer(
                            ignoring: !shouldShowPrev,
                            child: Opacity(
                              opacity: shouldShowPrev ? 1.0 : 0.0,
                              child: ClipOval(
                                child: NamidaBgBlur(
                                  blur: visiblePercentage * 2,
                                  child: Container(
                                    color: Colors.black.withOpacity(0.2 * visiblePercentage),
                                    padding: const EdgeInsets.all(10.0),
                                    child: NamidaIconButton(
                                        icon: null,
                                        horizontalPadding: 0.0,
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          Player.inst.previous();
                                          _resetTimer(hideControls: true);
                                        },
                                        child: Icon(
                                          Broken.previous,
                                          size: 30.0,
                                          color: itemsColor,
                                        )),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      ClipOval(
                        child: NamidaBgBlur(
                          blur: visiblePercentage * 2.5,
                          child: Container(
                            color: Colors.black.withOpacity(0.3 * visiblePercentage),
                            padding: const EdgeInsets.all(14.0),
                            child: Obx(
                              () {
                                final currentPosition = Player.inst.nowPlayingPosition;
                                final currentTotalDur = Player.inst.currentItemDuration?.inMilliseconds ?? 0;
                                final reachedLastPosition = currentPosition != 0 && (currentPosition - currentTotalDur).abs() < 200; // 200ms allowance
                                if (reachedLastPosition) {
                                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                    setControlsVisibily(true);
                                  });
                                }
                                final isLoading = Player.inst.shouldShowLoadingIndicator || VideoController.vcontroller.isBuffering;

                                return isLoading
                                    ? ThreeArchedCircle(
                                        color: itemsColor,
                                        size: 40.0,
                                      )
                                    : reachedLastPosition
                                        ? NamidaIconButton(
                                            icon: null,
                                            horizontalPadding: 0.0,
                                            padding: EdgeInsets.zero,
                                            onPressed: () async {
                                              await Player.inst.seek(Duration.zero);
                                              await Player.inst.play();
                                              _startTimer();
                                            },
                                            child: Icon(
                                              Broken.refresh,
                                              size: 40.0,
                                              color: itemsColor,
                                              key: const Key('replay'),
                                            ),
                                          )
                                        : NamidaIconButton(
                                            icon: null,
                                            horizontalPadding: 0.0,
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              Player.inst.togglePlayPause();
                                              _startTimer();
                                            },
                                            child: Obx(
                                              () => AnimatedSwitcher(
                                                duration: const Duration(milliseconds: 200),
                                                child: Player.inst.isPlaying
                                                    ? Icon(
                                                        Broken.pause,
                                                        size: 40.0,
                                                        color: itemsColor,
                                                        key: const Key('paused'),
                                                      )
                                                    : Icon(
                                                        Broken.play,
                                                        size: 40.0,
                                                        color: itemsColor,
                                                        key: const Key('playing'),
                                                      ),
                                              ),
                                            ),
                                          );
                              },
                            ),
                          ),
                        ),
                      ),
                      Obx(
                        () {
                          final shouldShowNext = Player.inst.currentIndex != Player.inst.currentQueueYoutube.length - 1;
                          return IgnorePointer(
                            ignoring: !shouldShowNext,
                            child: Opacity(
                              opacity: shouldShowNext ? 1.0 : 0.0,
                              child: ClipOval(
                                child: NamidaBgBlur(
                                  blur: visiblePercentage * 2,
                                  child: Container(
                                    color: Colors.black.withOpacity(0.2 * visiblePercentage),
                                    padding: const EdgeInsets.all(10.0),
                                    child: NamidaIconButton(
                                        icon: null,
                                        horizontalPadding: 0.0,
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          Player.inst.next();
                                          _resetTimer(hideControls: true);
                                        },
                                        child: Icon(
                                          Broken.next,
                                          size: 30.0,
                                          color: itemsColor,
                                        )),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(),
                    ],
                  );
                },
              ),
              Obx(
                () => Player.inst.shouldShowLoadingIndicator || VideoController.vcontroller.isBuffering
                    ? ThreeArchedCircle(
                        color: itemsColor,
                        size: 40.0,
                      )
                    : const SizedBox(),
              ),

              // ===== Seek Animators ====

              // -- left --
              _getSeekAnimatedContainer(
                controller: seekAnimationBackward1,
                isForward: false,
                isSecondary: false,
              ),
              _getSeekAnimatedContainer(
                controller: seekAnimationBackward2,
                isForward: false,
                isSecondary: true,
              ),

              // -- right --
              _getSeekAnimatedContainer(
                controller: seekAnimationForward1,
                isForward: true,
                isSecondary: false,
              ),
              _getSeekAnimatedContainer(
                controller: seekAnimationForward2,
                isForward: true,
                isSecondary: true,
              ),

              // ===========
              getSeekTextWidget(
                controller: seekAnimationBackward2,
                isForward: false,
              ),
              getSeekTextWidget(
                controller: seekAnimationForward2,
                isForward: true,
              ),

              // ========= Volume Slider ==========
              if (shouldShowVolumeSlider)
                Positioned(
                  right: context.width * 0.15,
                  child: Obx(
                    () {
                      final vol = _currentDeviceVolume.value;
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: vol == null
                            ? const SizedBox(key: Key('volume_hidden'))
                            : Material(
                                key: const Key('volume_visible'),
                                type: MaterialType.transparency,
                                child: Container(
                                  width: 42.0,
                                  decoration: BoxDecoration(
                                    color: context.theme.cardColor.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12.0.multipliedRadius),
                                  ),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 12.0),
                                      Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(8.0.multipliedRadius),
                                            ),
                                            width: 4.0,
                                            height: context.height * 0.4,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: CurrentColor.inst.color,
                                              borderRadius: BorderRadius.circular(8.0.multipliedRadius),
                                            ),
                                            width: 4.0,
                                            height: context.height * 0.4 * vol,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12.0),
                                      Text(
                                        "${(vol * 100).round()}%",
                                        style: context.textTheme.displaySmall,
                                      ),
                                      const SizedBox(height: 12.0),
                                    ],
                                  ),
                                ),
                              ),
                      );
                    },
                  ),
                )
            ],
          ],
        ),
      ),
    );
  }
}
