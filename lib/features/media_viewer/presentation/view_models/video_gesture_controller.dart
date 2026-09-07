import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/platform/brightness/brightness_service.dart';
import '../../domain/video_playback/video_playback.dart';

enum GestureFeedbackType { brightness, volume }

class VideoGestureController extends ChangeNotifier {
  VideoGestureController(this.playback, this.brightness);
  final VideoPlayback playback;
  final BrightnessService brightness;
  bool _disposed = false;
  bool _active = true;
  bool _left = true;
  bool _brightnessChanged = false;
  double? _brightness;
  double _volume = 1;
  Timer? _feedbackTimer;
  Timer? _seekTimer;
  GestureFeedbackType? overlayType;
  double? overlayLevel;
  bool seeking = false;
  bool _resume = false;
  double _seekDx = 0;
  Duration _seekStart = Duration.zero;
  Duration seekPosition = Duration.zero;
  Duration seekDuration = Duration.zero;
  Future<void> _tail = Future.value();

  Future<void> _enqueue(Future<void> Function() action) {
    final future = _tail.then((_) => action());
    _tail = future.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return future;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _feedback(GestureFeedbackType type, double level) {
    if (_disposed || !_active) return;
    overlayType = type;
    overlayLevel = level;
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 650), () {
      overlayType = null;
      overlayLevel = null;
      _notify();
    });
    _notify();
  }

  Future<void> startVertical(bool left) {
    _left = left;
    return _enqueue(() async {
      if (_disposed || !_active) return;
      if (left) {
        _brightness ??= await brightness.getApplicationBrightness();
        _feedback(GestureFeedbackType.brightness, _brightness!);
      } else {
        _volume = playback.value.volume;
        _feedback(GestureFeedbackType.volume, _volume);
      }
    });
  }

  Future<void> updateVertical(double dy, double height) {
    final left = _left;
    return _enqueue(() async {
      if (_disposed || !_active) return;
      final delta = -dy / (height > 0 ? height : 1) * 1.6;
      if (left) {
        final current = _brightness;
        if (current == null) return;
        _brightness = (current + delta).clamp(0.0, 1.0);
        _brightnessChanged = true;
        await brightness.setApplicationBrightness(_brightness!);
        _feedback(GestureFeedbackType.brightness, _brightness!);
      } else {
        _volume = (_volume + delta).clamp(0.0, 1.0);
        await playback.setVolume(_volume);
        _feedback(GestureFeedbackType.volume, _volume);
      }
    });
  }

  Future<void> startSeek() {
    final value = playback.value;
    if (!_active ||
        _disposed ||
        !value.isInitialized ||
        value.duration <= Duration.zero) {
      return Future.value();
    }
    _seekTimer?.cancel();
    seeking = true;
    _resume = value.isPlaying;
    seekDuration = value.duration;
    seekPosition = value.position;
    _seekStart = value.position;
    _seekDx = 0;
    _notify();
    return _enqueue(() async {
      if (_active && !_disposed) await playback.pause();
    });
  }

  Future<void> updateSeek(double dx, double width) {
    if (!seeking || !_active || _disposed) return Future.value();
    _seekDx += dx;
    final fraction = (_seekDx / (width > 0 ? width : 1)).clamp(-1.0, 1.0);
    final target =
        _seekStart.inMilliseconds +
        (fraction * seekDuration.inMilliseconds).round();
    seekPosition = Duration(
      milliseconds: target.clamp(0, seekDuration.inMilliseconds),
    );
    final position = seekPosition;
    _notify();
    return _enqueue(() async {
      if (_active && !_disposed) await playback.seekTo(position);
    });
  }

  Future<void> endSeek() {
    if (!seeking) return Future.value();
    seeking = false;
    final resume = _resume;
    _resume = false;
    _seekTimer?.cancel();
    _seekTimer = Timer(const Duration(milliseconds: 450), () {
      seekPosition = Duration.zero;
      seekDuration = Duration.zero;
      _notify();
    });
    _notify();
    return _enqueue(() async {
      if (resume && _active && !_disposed) await playback.play();
    });
  }

  void activate() {
    _active = true;
  }

  Future<void> deactivate() {
    _active = false;
    seeking = false;
    _resume = false;
    _feedbackTimer?.cancel();
    _seekTimer?.cancel();
    overlayType = null;
    overlayLevel = null;
    return _enqueue(_resetBrightness);
  }

  Future<void> _resetBrightness() async {
    if (_brightnessChanged) {
      try {
        await brightness.resetApplicationBrightness();
      } finally {
        _brightnessChanged = false;
        _brightness = null;
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(deactivate().catchError((Object _) {}));
    super.dispose();
  }
}
