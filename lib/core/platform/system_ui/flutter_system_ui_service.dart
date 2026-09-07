import 'package:flutter/services.dart';

import 'system_ui_service.dart';

class FlutterSystemUiService implements SystemUiService {
  @override
  Future<void> setFullscreen(bool enabled) async {
    await SystemChrome.setEnabledSystemUIMode(
      enabled ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  @override
  Future<void> setOrientationLock(AppOrientationLock lock) async {
    final orientations = switch (lock) {
      AppOrientationLock.system => SystemUiService.defaultOrientations(),
      AppOrientationLock.portrait => const [DeviceOrientation.portraitUp],
      AppOrientationLock.landscape => const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    };

    await SystemChrome.setPreferredOrientations(orientations);
  }

  @override
  Future<void> reset() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(
      SystemUiService.defaultOrientations(),
    );
  }
}
