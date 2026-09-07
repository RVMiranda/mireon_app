import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/platform/audio/audio_focus_service.dart';
import '../../../../core/platform/audio/audio_interruption.dart';
import '../../domain/video_playback/video_playback.dart';
import '../../domain/video_playback/video_playback_value.dart';

class VideoPlayerVideoPlayback implements VideoPlayback {
  VideoPlayerVideoPlayback({this._audioFocusService})
    : _notifier = ValueNotifier(const VideoPlaybackValue.idle());

  final AudioFocusService? _audioFocusService;

  final ValueNotifier<VideoPlaybackValue> _notifier;

  VideoPlayerController? _controller;
  int _loadToken = 0;
  bool _disposed = false;

  bool _audioConfigured = false;
  bool _resumeAfterInterruption = false;
  StreamSubscription<AudioInterruption>? _interruptionSub;
  StreamSubscription<void>? _noisySub;

  @override
  ValueListenable<VideoPlaybackValue> get valueListenable => _notifier;

  @override
  VideoPlaybackValue get value => _notifier.value;

  @override
  Future<void> loadFile(String filePath) async {
    final loadToken = ++_loadToken;

    await _disposeController();

    await _ensureAudio();

    if (_disposed) {
      return;
    }

    final VideoPlayerController controller;
    final uri = Uri.tryParse(filePath);

    if (filePath.startsWith('content://') && uri != null) {
      controller = VideoPlayerController.contentUri(uri);
    } else if ((filePath.startsWith('http://') ||
            filePath.startsWith('https://')) &&
        uri != null) {
      _notifier.value = const VideoPlaybackValue.idle().copyWith(
        errorDescription: 'Este contenido no está disponible localmente.',
      );
      return;
    } else if (filePath.startsWith('file://') && uri != null) {
      controller = VideoPlayerController.file(File(uri.toFilePath()));
    } else {
      controller = VideoPlayerController.file(File(filePath));
    }

    _controller = controller;

    void onUpdate() {
      final current = _controller;
      if (_disposed || current == null) {
        return;
      }

      final v = current.value;
      _notifier.value = _notifier.value.copyWith(
        isInitialized: v.isInitialized,
        isBuffering: v.isBuffering,
        isPlaying: v.isPlaying,
        position: v.position,
        duration: v.duration,
        aspectRatio: v.isInitialized
            ? v.aspectRatio
            : _notifier.value.aspectRatio,
        platformController: current,
        errorDescription: v.hasError ? 'Error en la reproducción.' : null,
      );
    }

    controller.addListener(onUpdate);

    try {
      await controller.initialize();
    } catch (_) {
      if (!_disposed && loadToken == _loadToken) {
        _notifier.value = const VideoPlaybackValue.idle().copyWith(
          errorDescription: 'No se pudo inicializar el vídeo.',
        );
      }
      await _disposeController();
      return;
    }

    if (_disposed || loadToken != _loadToken) {
      await _disposeController();
      return;
    }

    onUpdate();
  }

  Future<void> _ensureAudio() async {
    final audio = _audioFocusService;
    if (audio == null || _audioConfigured || _disposed) {
      return;
    }

    await audio.ensureConfiguredForMedia();

    _interruptionSub ??= audio.interruptionStream.listen((event) async {
      final controller = _controller;
      if (_disposed || controller == null) {
        return;
      }

      if (event.began) {
        _resumeAfterInterruption = controller.value.isPlaying;
        try {
          await controller.pause();
        } catch (_) {
          // ignore
        }
        return;
      }

      if (_resumeAfterInterruption) {
        _resumeAfterInterruption = false;
        try {
          await audio.setActive(true);
          await controller.play();
        } catch (_) {
          // ignore
        }
      }
    });

    _noisySub ??= audio.becomingNoisyStream.listen((_) async {
      final controller = _controller;
      if (_disposed || controller == null) {
        return;
      }
      try {
        await controller.pause();
      } catch (_) {
        // ignore
      }
    });

    _audioConfigured = true;
  }

  @override
  Future<void> play() async {
    final controller = _controller;
    if (_disposed || controller == null) {
      return;
    }

    if (controller.value.isInitialized) {
      if (controller.value.position >= controller.value.duration &&
          controller.value.duration > Duration.zero) {
        await controller.seekTo(Duration.zero);
      }
      await controller.play();
    }
  }

  @override
  Future<void> pause() async {
    final controller = _controller;
    if (_disposed || controller == null) {
      return;
    }
    await controller.pause();
  }

  @override
  Future<void> seekTo(Duration position) async {
    final controller = _controller;
    if (_disposed || controller == null) {
      return;
    }
    await controller.seekTo(position);
  }

  @override
  Future<void> setVolume(double volume) async {
    final controller = _controller;
    if (_disposed || controller == null) {
      return;
    }
    final clamped = volume.clamp(0.0, 1.0);
    await controller.setVolume(clamped);
    _notifier.value = _notifier.value.copyWith(
      volume: clamped,
      isMuted: clamped == 0.0,
    );
  }

  @override
  Future<void> setLooping(bool looping) async {
    final controller = _controller;
    if (_disposed || controller == null) return;
    await controller.setLooping(looping);
  }

  @override
  Future<void> toggleMute() async {
    final controller = _controller;
    if (_disposed || controller == null) {
      return;
    }
    final nextMuted = !_notifier.value.isMuted;
    final targetVol = nextMuted
        ? 0.0
        : (_notifier.value.volume > 0 ? _notifier.value.volume : 1.0);
    await controller.setVolume(targetVol);
    _notifier.value = _notifier.value.copyWith(isMuted: nextMuted);
  }

  @override
  Future<void> release() async {
    await _disposeController();
    if (_disposed) {
      return;
    }

    try {
      await _audioFocusService?.setActive(false);
    } catch (_) {
      // ignore
    }

    _notifier.value = const VideoPlaybackValue.idle();
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    await _disposeController();

    try {
      await _audioFocusService?.setActive(false);
    } catch (_) {
      // ignore
    }

    await _interruptionSub?.cancel();
    await _noisySub?.cancel();

    _notifier.dispose();
  }

  Future<void> _disposeController() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    _controller = null;

    try {
      await controller.pause();
    } catch (_) {
      // ignore
    }

    try {
      await controller.dispose();
    } catch (_) {
      // ignore
    }
  }
}
