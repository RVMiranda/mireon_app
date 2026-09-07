import 'package:flutter_test/flutter_test.dart';
import 'package:mireon/features/media_viewer/domain/video_playback/video_playback_value.dart';

void main() {
  group('VideoPlaybackValue', () {
    test('idle factory creates default video playback state', () {
      const state = VideoPlaybackValue.idle();
      expect(state.isInitialized, isFalse);
      expect(state.isPlaying, isFalse);
      expect(state.position, equals(Duration.zero));
      expect(state.duration, equals(Duration.zero));
      expect(state.volume, equals(1.0));
      expect(state.isMuted, isFalse);
    });

    test('copyWith updates volume and muted state correctly', () {
      const state = VideoPlaybackValue.idle();
      final updated = state.copyWith(volume: 0.5, isPlaying: true);

      expect(updated.volume, equals(0.5));
      expect(updated.isPlaying, isTrue);
      expect(updated.isMuted, isFalse);

      final muted = updated.copyWith(volume: 0.0, isMuted: true);
      expect(muted.volume, equals(0.0));
      expect(muted.isMuted, isTrue);
    });
  });
}
