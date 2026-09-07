import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mireon/features/media_viewer/domain/video_playback/video_playback.dart';
import 'package:mireon/features/media_viewer/domain/video_playback/video_playback_value.dart';
import 'package:mireon/features/media_viewer/presentation/view_models/video_pane_controller.dart';

class PlaybackFake implements VideoPlayback {
  final notifier = ValueNotifier(const VideoPlaybackValue.idle());
  final loaded = <String>[];
  int plays = 0;
  bool disposed = false;
  @override
  VideoPlaybackValue get value => notifier.value;
  @override
  ValueListenable<VideoPlaybackValue> get valueListenable => notifier;
  @override
  Future<void> loadFile(String path) async {
    loaded.add(path);
    notifier.value = value.copyWith(isInitialized: true);
  }

  @override
  Future<void> play() async {
    plays++;
    notifier.value = value.copyWith(isPlaying: true);
  }

  @override
  Future<void> pause() async {
    notifier.value = value.copyWith(isPlaying: false);
  }

  @override
  Future<void> release() async {
    notifier.value = const VideoPlaybackValue.idle();
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    notifier.dispose();
  }

  @override
  Future<void> seekTo(Duration position) async {}
  @override
  Future<void> setVolume(double volume) async {}
  @override
  Future<void> toggleMute() async {}
}

void main() {
  test('inactive then paused retains the original resume intent', () async {
    final playback = PlaybackFake();
    final controller = VideoPaneController(playback, (id) async => id);
    await controller.activate('video');
    await controller.setForeground(false);
    await controller.setForeground(false);
    await controller.setForeground(true);
    expect(playback.plays, 2);
    await controller.dispose();
  });
  test('deactivation during resolution prevents stale autoplay', () async {
    final path = Completer<String?>();
    final playback = PlaybackFake();
    final controller = VideoPaneController(playback, (_) => path.future);
    final activation = controller.activate('video');
    final release = controller.deactivate();
    path.complete('file');
    await Future.wait([activation, release]);
    expect(playback.loaded, isEmpty);
    expect(playback.plays, 0);
    await controller.dispose();
    expect(playback.disposed, isTrue);
  });
}
