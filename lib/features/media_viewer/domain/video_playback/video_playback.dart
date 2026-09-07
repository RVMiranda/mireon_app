import 'package:flutter/foundation.dart';

import 'video_playback_value.dart';

abstract interface class VideoPlayback {
  ValueListenable<VideoPlaybackValue> get valueListenable;
  VideoPlaybackValue get value;

  Future<void> loadFile(String filePath);
  Future<void> play();
  Future<void> pause();
  Future<void> seekTo(Duration position);
  Future<void> setVolume(double volume);
  Future<void> toggleMute();

  /// Releases any underlying platform resources (player instance, textures, etc)
  /// but keeps this object reusable.
  Future<void> release();

  /// Disposes this object and makes it unusable.
  Future<void> dispose();
}
