import 'package:flutter/services.dart';

enum AppOrientationLock { system, portrait, landscape }

abstract interface class SystemUiService {
  Future<void> setFullscreen(bool enabled);

  Future<void> setOrientationLock(AppOrientationLock lock);

  Future<void> reset();

  /// Returns the orientations used for [AppOrientationLock.system].
  static List<DeviceOrientation> defaultOrientations() {
    return const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ];
  }
}
