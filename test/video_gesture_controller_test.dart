import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mireon/core/platform/brightness/brightness_service.dart';
import 'package:mireon/features/media_viewer/presentation/view_models/video_gesture_controller.dart';
import 'package:mireon/features/media_viewer/data/video_playback/video_player_video_playback.dart';
import 'video_pane_controller_test.dart' show PlaybackFake;

class BrightnessFake implements BrightnessService {
  double value = 0.5;
  bool reset = false;
  Completer<void>? pendingWrite;
  @override
  Future<double> getApplicationBrightness() async => value;
  @override
  Future<void> setApplicationBrightness(double next) async {
    await pendingWrite?.future;
    value = next;
  }

  @override
  Future<void> resetApplicationBrightness() async {
    reset = true;
    value = 0.5;
  }
}

void main() {
  test(
    'brightness reset follows an in-flight gesture when the pane closes',
    () async {
      final playback = PlaybackFake();
      final brightness = BrightnessFake();
      final gestures = VideoGestureController(playback, brightness);
      await gestures.startVertical(true);
      brightness.pendingWrite = Completer<void>();
      final update = gestures.updateVertical(-20, 100);
      await Future<void>.delayed(Duration.zero);
      final deactivate = gestures.deactivate();
      brightness.pendingWrite!.complete();
      await Future.wait([update, deactivate]);
      expect(brightness.reset, isTrue);
      expect(brightness.value, 0.5);
      gestures.dispose();
      await playback.dispose();
    },
  );
  test('cancelled pane never resumes after seek', () async {
    final playback = PlaybackFake();
    playback.notifier.value = playback.value.copyWith(
      isInitialized: true,
      isPlaying: true,
      duration: const Duration(seconds: 10),
    );
    final gestures = VideoGestureController(playback, BrightnessFake());
    await gestures.startSeek();
    await gestures.updateSeek(1000, 100);
    expect(gestures.seekPosition, const Duration(seconds: 10));
    await gestures.deactivate();
    await gestures.endSeek();
    expect(playback.plays, 0);
    gestures.dispose();
    await playback.dispose();
  });
  test(
    'the local player rejects network media without creating a decoder',
    () async {
      final playback = VideoPlayerVideoPlayback();
      await playback.loadFile('https://example.invalid/private.mp4');
      expect(playback.value.platformController, isNull);
      expect(playback.value.errorDescription, isNotNull);
      await playback.dispose();
    },
  );
}
