import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mireon/core/platform/system_ui/system_ui_service.dart';
import 'package:mireon/features/media_viewer/domain/video_playback/video_playback.dart';

import 'package:mireon/features/media_viewer/presentation/widgets/zoom_control_panel.dart';

class VideoControls extends StatefulWidget {
  const VideoControls({
    super.key,
    required this.playback,
    required this.isFullscreen,
    required this.orientationLock,
    required this.isZoomMenuVisible,
    required this.currentScale,
    required this.onToggleFullscreen,
    required this.onCycleOrientationLock,
    required this.onToggleZoomMenu,
    required this.onSetZoom,
  });

  final VideoPlayback playback;
  final bool isFullscreen;
  final AppOrientationLock orientationLock;
  final bool isZoomMenuVisible;
  final double currentScale;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onCycleOrientationLock;
  final VoidCallback onToggleZoomMenu;
  final ValueChanged<double> onSetZoom;

  @override
  State<VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<VideoControls> {
  @override
  void initState() {
    super.initState();
    widget.playback.valueListenable.addListener(_onControllerUpdate);
  }

  @override
  void didUpdateWidget(covariant VideoControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playback != widget.playback) {
      oldWidget.playback.valueListenable.removeListener(_onControllerUpdate);
      widget.playback.valueListenable.addListener(_onControllerUpdate);
    }
  }

  @override
  void dispose() {
    widget.playback.valueListenable.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.playback.value;
    final duration = value.duration;
    final position = value.position;
    final isEnded = position >= duration && duration > Duration.zero;

    final maxMs = duration.inMilliseconds <= 0
        ? 1.0
        : duration.inMilliseconds.toDouble();
    final currentMs = position.inMilliseconds
        .clamp(0, duration.inMilliseconds)
        .toDouble();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PANOC DE CONTROL DE ZOOM FLOTANTE
        if (widget.isZoomMenuVisible) ...[
          ZoomControlPanel(
            currentScale: widget.currentScale,
            onSetZoom: widget.onSetZoom,
            onClose: widget.onToggleZoomMenu,
          ),
          const SizedBox(height: 10),
        ],
        // 1. BARRA DE PROGRESO FLOTANTE TIPO CÁPSULA (Estilo Imagen 2)
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white24, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () async {
                  if (value.isPlaying) {
                    await widget.playback.pause();
                  } else {
                    await widget.playback.play();
                  }
                },
                icon: Icon(
                  isEnded
                      ? Icons.replay_rounded
                      : (value.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded),
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      _fmt(position),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 5,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                            elevation: 2,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12,
                          ),
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white30,
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: currentMs,
                          min: 0,
                          max: maxMs,
                          onChanged: (next) {
                            widget.playback.seekTo(
                              Duration(milliseconds: next.round()),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _fmt(duration),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () {
                  unawaited(widget.playback.toggleMute());
                },
                icon: Icon(
                  value.isMuted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: value.isMuted ? 'Activar sonido' : 'Silenciar',
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // 2. CAJA DE CONTROLES SECUNDARIOS SEPARADA ABAJO
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () async {
                  final target = position - const Duration(seconds: 10);
                  await widget.playback.seekTo(
                    target < Duration.zero ? Duration.zero : target,
                  );
                },
                icon: const Icon(
                  Icons.replay_10_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                tooltip: 'Retroceder 10s',
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () async {
                  final target = position + const Duration(seconds: 10);
                  await widget.playback.seekTo(
                    target > duration ? duration : target,
                  );
                },
                icon: const Icon(
                  Icons.forward_10_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                tooltip: 'Adelantar 10s',
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: widget.onToggleZoomMenu,
                icon: Icon(
                  widget.isZoomMenuVisible
                      ? Icons.zoom_in_map_rounded
                      : Icons.zoom_in_rounded,
                  color: widget.isZoomMenuVisible
                      ? Colors.amberAccent
                      : Colors.white,
                  size: 22,
                ),
                tooltip: 'Control de zoom',
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: widget.onCycleOrientationLock,
                icon: Icon(
                  switch (widget.orientationLock) {
                    AppOrientationLock.system => Icons.screen_rotation_rounded,
                    AppOrientationLock.landscape =>
                      Icons.stay_current_landscape_rounded,
                    AppOrientationLock.portrait =>
                      Icons.stay_current_portrait_rounded,
                  },
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: 'Orientación',
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: widget.onToggleFullscreen,
                icon: Icon(
                  widget.isFullscreen
                      ? Icons.fullscreen_exit_rounded
                      : Icons.fullscreen_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                tooltip: 'Pantalla completa',
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _fmt(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:$m:$s';
    }

    return '$m:$s';
  }
}
