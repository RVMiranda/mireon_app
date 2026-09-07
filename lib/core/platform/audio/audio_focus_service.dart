import 'audio_interruption.dart';

abstract interface class AudioFocusService {
  Future<void> ensureConfiguredForMedia();

  Future<bool> setActive(bool active);

  Stream<AudioInterruption> get interruptionStream;

  Stream<void> get becomingNoisyStream;
}
