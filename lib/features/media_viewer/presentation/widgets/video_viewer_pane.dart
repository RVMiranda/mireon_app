import '../view_models/video_gesture_controller.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/media_actions_controller.dart';
import '../view_models/video_pane_controller.dart';

import 'package:mireon/features/media_library/domain/entities/media_item.dart';
import 'package:mireon/features/media_library/presentation/view_models/media_library_providers.dart';
import 'package:mireon/core/platform/providers/device_controls_providers.dart';
import 'package:mireon/core/platform/system_ui/system_ui_service.dart';
import 'package:mireon/features/media_viewer/presentation/view_models/video_playback_providers.dart';
import 'package:mireon/features/media_viewer/presentation/widgets/conditional_horizontal_drag_gesture_recognizer.dart';
import 'package:mireon/features/media_viewer/presentation/widgets/gesture_feedback_overlay.dart';
import 'package:mireon/features/media_viewer/presentation/widgets/seek_feedback_overlay.dart';
import 'package:mireon/features/media_viewer/presentation/widgets/video_surface.dart';

import 'package:mireon/features/media_viewer/presentation/widgets/video_controls.dart';
import 'package:mireon/features/media_viewer/presentation/widgets/video_first_time_guide_dialog.dart';

class VideoViewerPane extends ConsumerStatefulWidget {
  const VideoViewerPane({
    required this.item,
    required this.isActive,
    required this.controlsVisible,
    required this.isFullscreen,
    required this.orientationLock,
    required this.onToggleControls,
    required this.onToggleFullscreen,
    required this.onCycleOrientationLock,
    super.key,
  });

  final MediaItem item;
  final bool isActive;
  final bool controlsVisible;
  final bool isFullscreen;
  final AppOrientationLock orientationLock;
  final VoidCallback onToggleControls;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onCycleOrientationLock;

  @override
  ConsumerState<VideoViewerPane> createState() => _VideoViewerPaneState();
}

class _VideoViewerPaneState extends ConsumerState<VideoViewerPane>
    with WidgetsBindingObserver {
  late final _playback = ref.read(videoPlaybackFactoryProvider).call();
  late final _session = VideoPaneController(
    _playback,
    (id) => ref.read(mediaFilePathProvider(id).future),
  );

  final TransformationController _transformController =
      TransformationController();

  bool _lastZoomed = false;

  static const double _edgeSwipeZone = 24;

  late final _gestures = VideoGestureController(
    _playback,
    ref.read(brightnessServiceProvider),
  );
  void _onGestureChanged() {
    if (mounted) setState(() {});
  }

  void _gestureAction(Future<void> action) {
    unawaited(action.catchError((Object _) {}));
  }

  bool get _isZoomed {
    final m = _transformController.value;
    final sx = m.storage[0];
    final sy = m.storage[5];
    return (sx - 1.0).abs() > 0.01 || (sy - 1.0).abs() > 0.01;
  }

  @override
  void didUpdateWidget(covariant VideoViewerPane oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _initVideo();
      } else {
        _releaseVideo();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _transformController.addListener(_onTransformChanged);
    _gestures.addListener(_onGestureChanged);
    if (widget.isActive) {
      _initVideo();
      _checkFirstTimeVideoGuide();
    }
  }

  Future<void> _checkFirstTimeVideoGuide() async {
    try {
      final show = await ref.read(viewerPreferencesProvider).claimVideoGuide();
      if (show && mounted && widget.isActive) {
        await showDialog<void>(
          context: context,
          builder: (context) => const VideoFirstTimeGuideDialog(),
        );
      }
    } catch (_) {
      /* Preferences must not interrupt playback. */
    }
  }

  @override
  void dispose() {
    _gestures.removeListener(_onGestureChanged);
    _gestures.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _transformController.removeListener(_onTransformChanged);
    _transformController.dispose();
    unawaited(_session.dispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.isActive) {
      return;
    }

    final foreground = state == AppLifecycleState.resumed;
    if (foreground) {
      _gestures.activate();
    } else {
      _gestureAction(_gestures.deactivate());
    }
    _gestureAction(_session.setForeground(foreground));
  }

  void _onTransformChanged() {
    final zoomedNow = _isZoomed;
    if (zoomedNow != _lastZoomed) {
      _lastZoomed = zoomedNow;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _initVideo() async {
    _gestures.activate();
    try {
      await _session.activate(widget.item.id);
    } catch (_) {
      await _session.deactivate();
    }
  }

  Future<void> _releaseVideo() async {
    _gestureAction(_gestures.deactivate());
    _transformController.value = Matrix4.identity();
    _lastZoomed = false;
    await _session.deactivate();
  }

  bool _showZoomMenu = false;

  void _setZoomScale(double scale) {
    _transformController.value = Matrix4.diagonal3Values(scale, scale, 1.0);
    _onTransformChanged();
  }

  void _toggleZoomMenu() {
    setState(() {
      _showZoomMenu = !_showZoomMenu;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ValueListenableBuilder(
          valueListenable: _playback.valueListenable,
          builder: (context, value, _) {
            if (value.errorDescription != null) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onToggleControls,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.video_camera_back_outlined,
                          size: 48,
                          color: Colors.orangeAccent,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No se pudo reproducir el vídeo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          value.errorDescription!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _initVideo,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Reintentar'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white24,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final isBuffering = value.isBuffering;

            if (!value.isInitialized) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onToggleControls,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        'Cargando vídeo...',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final overlayType = _gestures.overlayType;
            final overlayLevel = _gestures.overlayLevel;
            final enableDeviceGestures = !_isZoomed;
            final isEnded =
                value.position >= value.duration &&
                value.duration > Duration.zero;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onToggleControls,
              onDoubleTap: () async {
                if (_isZoomed) {
                  _transformController.value = Matrix4.identity();
                  return;
                }
                if (value.isPlaying) {
                  await _playback.pause();
                } else {
                  await _playback.play();
                }
              },

              onVerticalDragStart: enableDeviceGestures
                  ? (d) {
                      _gestureAction(
                        _gestures.startVertical(
                          d.localPosition.dx < constraints.maxWidth / 2,
                        ),
                      );
                    }
                  : null,
              onVerticalDragUpdate: enableDeviceGestures
                  ? (d) {
                      _gestureAction(
                        _gestures.updateVertical(
                          d.delta.dy,
                          constraints.maxHeight,
                        ),
                      );
                    }
                  : null,
              child: RawGestureDetector(
                gestures: {
                  ConditionalHorizontalDragGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                        ConditionalHorizontalDragGestureRecognizer
                      >(
                        () => ConditionalHorizontalDragGestureRecognizer(
                          shouldAccept: (local) {
                            if (_isZoomed) {
                              return false;
                            }
                            final w = constraints.maxWidth;
                            if (w <= 0) {
                              return false;
                            }
                            return local.dx > _edgeSwipeZone &&
                                local.dx < (w - _edgeSwipeZone);
                          },
                        ),
                        (recognizer) {
                          recognizer.onStart = (d) =>
                              _gestureAction(_gestures.startSeek());

                          recognizer.onUpdate = (d) {
                            unawaited(
                              _gestures
                                  .updateSeek(d.delta.dx, constraints.maxWidth)
                                  .catchError((Object _) {}),
                            );
                          };

                          recognizer.onEnd = (_) =>
                              _gestureAction(_gestures.endSeek());
                          recognizer.onCancel = () =>
                              _gestureAction(_gestures.endSeek());
                        },
                      ),
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: ClipRect(
                        child: InteractiveViewer(
                          transformationController: _transformController,
                          panEnabled: _isZoomed,
                          scaleEnabled: true,
                          minScale: 1,
                          maxScale: 4,
                          boundaryMargin: const EdgeInsets.all(800),
                          child: VideoSurface(value: value),
                        ),
                      ),
                    ),
                    if (isBuffering)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    if (widget.controlsVisible &&
                        !isBuffering &&
                        !_gestures.seeking)
                      AnimatedScale(
                        duration: const Duration(milliseconds: 150),
                        scale: widget.controlsVisible ? 1.0 : 0.8,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(40),
                            onTap: () async {
                              if (value.isPlaying) {
                                await _playback.pause();
                              } else {
                                await _playback.play();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white24,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                isEnded
                                    ? Icons.replay_rounded
                                    : (value.isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded),
                                color: Colors.white,
                                size: 44,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_gestures.seeking &&
                        _gestures.seekDuration != Duration.zero)
                      SeekFeedbackOverlay(
                        position: _gestures.seekPosition,
                        duration: _gestures.seekDuration,
                      )
                    else if (overlayType != null && overlayLevel != null)
                      GestureFeedbackOverlay(
                        type: overlayType,
                        level: overlayLevel,
                      ),
                    if (widget.controlsVisible)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 24,
                          ),
                          child: VideoControls(
                            playback: _playback,
                            isFullscreen: widget.isFullscreen,
                            orientationLock: widget.orientationLock,
                            isZoomMenuVisible: _showZoomMenu,
                            currentScale: _transformController.value.storage[0],
                            onToggleFullscreen: widget.onToggleFullscreen,
                            onCycleOrientationLock:
                                widget.onCycleOrientationLock,
                            onToggleZoomMenu: _toggleZoomMenu,
                            onSetZoom: _setZoomScale,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
