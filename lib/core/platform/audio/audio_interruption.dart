import 'package:flutter/foundation.dart';

enum AudioInterruptionType { pause, duck, unknown }

@immutable
class AudioInterruption {
  const AudioInterruption({required this.began, required this.type});

  final bool began;
  final AudioInterruptionType type;
}
