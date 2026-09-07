import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/platform/providers/device_controls_providers.dart';
import '../../data/video_playback/video_player_video_playback.dart';
import '../../domain/video_playback/video_playback.dart';

typedef VideoPlaybackFactory = VideoPlayback Function();

final videoPlaybackFactoryProvider = Provider<VideoPlaybackFactory>((ref) {
  final audioFocus = ref.watch(audioFocusServiceProvider);
  return () => VideoPlayerVideoPlayback(audioFocusService: audioFocus);
});
