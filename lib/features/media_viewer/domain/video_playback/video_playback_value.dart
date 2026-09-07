import 'package:flutter/foundation.dart';

@immutable
class VideoPlaybackValue {
  const VideoPlaybackValue({
    required this.isInitialized,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.aspectRatio,
    required this.platformController,
    required this.errorDescription,
    this.isMuted = false,
    this.volume = 1.0,
    this.isBuffering = false,
  });

  const VideoPlaybackValue.idle()
    : isInitialized = false,
      isBuffering = false,
      isPlaying = false,
      position = Duration.zero,
      duration = Duration.zero,
      aspectRatio = 16 / 9,
      platformController = null,
      errorDescription = null,
      isMuted = false,
      volume = 1.0;

  final bool isInitialized;
  final bool isBuffering;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double aspectRatio;
  final bool isMuted;
  final double volume;

  /// Opaque handle used only by presentation widgets.
  ///
  /// For `video_player`, this will be a `VideoPlayerController`.
  final Object? platformController;

  final String? errorDescription;

  VideoPlaybackValue copyWith({
    bool? isInitialized,
    bool? isBuffering,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? aspectRatio,
    Object? platformController,
    String? errorDescription,
    bool? isMuted,
    double? volume,
  }) {
    return VideoPlaybackValue(
      isInitialized: isInitialized ?? this.isInitialized,
      isBuffering: isBuffering ?? this.isBuffering,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      platformController: platformController ?? this.platformController,
      errorDescription: errorDescription,
      isMuted: isMuted ?? this.isMuted,
      volume: volume ?? this.volume,
    );
  }
}
