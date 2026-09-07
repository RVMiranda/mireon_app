import '../../domain/video_playback/video_playback.dart';

/// Owns asynchronous loading and lifecycle intent, independently of the widget.
class VideoPaneController {
  VideoPaneController(this.playback, this.resolve);
  final VideoPlayback playback;
  final Future<String?> Function(String) resolve;
  int _generation = 0;
  bool _closed = false;
  bool _active = false;
  bool _foreground = true;
  bool _resume = false;
  Future<void> _tail = Future.value();

  Future<void> _enqueue(Future<void> Function() action) {
    final future = _tail.then((_) => action());
    _tail = future.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return future;
  }

  Future<void> activate(String id) {
    final generation = ++_generation;
    _active = true;
    return _enqueue(() async {
      if (_closed || !_active || generation != _generation) return;
      final path = await resolve(id);
      if (_closed || !_active || generation != _generation) return;
      if (path == null || path.isEmpty) {
        await playback.release();
        return;
      }
      await playback.loadFile(path);
      if (_closed || !_active || generation != _generation) {
        await playback.release();
        return;
      }
      if (_foreground) await playback.play();
    });
  }

  Future<void> deactivate() {
    _active = false;
    _resume = false;
    _generation++;
    return _enqueue(playback.release);
  }

  Future<void> setForeground(bool foreground) {
    if (_foreground == foreground || _closed) return Future.value();
    _foreground = foreground;
    if (!foreground) {
      _resume = _active && playback.value.isPlaying;
      return _enqueue(playback.pause);
    }
    final shouldResume = _resume && _active;
    _resume = false;
    return shouldResume
        ? _enqueue(() async {
            if (!_closed && _active && _foreground) await playback.play();
          })
        : Future.value();
  }

  Future<void> dispose() {
    if (_closed) return _tail;
    _closed = true;
    _generation++;
    _active = false;
    return _enqueue(playback.dispose);
  }
}
