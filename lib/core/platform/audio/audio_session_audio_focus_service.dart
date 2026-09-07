import 'dart:async';

import 'package:audio_session/audio_session.dart' as audio;

import 'audio_focus_service.dart';
import 'audio_interruption.dart';

class AudioSessionAudioFocusService implements AudioFocusService {
  AudioSessionAudioFocusService();

  audio.AudioSession? _session;
  StreamController<AudioInterruption>? _interruptions;
  StreamController<void>? _noisy;

  StreamSubscription<audio.AudioInterruptionEvent>? _interruptionSub;
  StreamSubscription<void>? _noisySub;

  bool _configured = false;

  @override
  Stream<AudioInterruption> get interruptionStream {
    _interruptions ??= StreamController<AudioInterruption>.broadcast();
    return _interruptions!.stream;
  }

  @override
  Stream<void> get becomingNoisyStream {
    _noisy ??= StreamController<void>.broadcast();
    return _noisy!.stream;
  }

  @override
  Future<void> ensureConfiguredForMedia() async {
    if (_configured) {
      return;
    }

    final session = await audio.AudioSession.instance;
    _session = session;

    // Good default for video playback: treated like music/media.
    await session.configure(const audio.AudioSessionConfiguration.music());

    _interruptions ??= StreamController<AudioInterruption>.broadcast();
    _noisy ??= StreamController<void>.broadcast();

    _interruptionSub ??= session.interruptionEventStream.listen((event) {
      final type = switch (event.type) {
        audio.AudioInterruptionType.pause => AudioInterruptionType.pause,
        audio.AudioInterruptionType.duck => AudioInterruptionType.duck,
        audio.AudioInterruptionType.unknown => AudioInterruptionType.unknown,
      };

      _interruptions?.add(AudioInterruption(began: event.begin, type: type));
    });

    _noisySub ??= session.becomingNoisyEventStream.listen((_) {
      _noisy?.add(null);
    });

    _configured = true;
  }

  @override
  Future<bool> setActive(bool active) async {
    final session = _session ?? await audio.AudioSession.instance;
    _session = session;
    return session.setActive(active);
  }

  Future<void> dispose() async {
    await _interruptionSub?.cancel();
    await _noisySub?.cancel();
    await _interruptions?.close();
    await _noisy?.close();
  }
}
