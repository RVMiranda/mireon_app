import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../domain/video_playback/video_playback_value.dart';

class VideoSurface extends StatelessWidget {
  const VideoSurface({required this.value, super.key});

  final VideoPlaybackValue value;

  @override
  Widget build(BuildContext context) {
    final platform = value.platformController;
    if (platform is! VideoPlayerController || !platform.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final aspect = (value.aspectRatio > 0 && value.aspectRatio.isFinite)
        ? value.aspectRatio
        : (platform.value.aspectRatio > 0
              ? platform.value.aspectRatio
              : 16 / 9);

    return AspectRatio(aspectRatio: aspect, child: VideoPlayer(platform));
  }
}
