import 'package:screen_brightness/screen_brightness.dart';

import 'brightness_service.dart';

class ScreenBrightnessService implements BrightnessService {
  @override
  Future<double> getApplicationBrightness() async {
    final v = await ScreenBrightness.instance.application;
    return v.clamp(0.0, 1.0);
  }

  @override
  Future<void> setApplicationBrightness(double value) async {
    final clamped = value.clamp(0.0, 1.0);
    await ScreenBrightness.instance.setApplicationScreenBrightness(clamped);
  }

  @override
  Future<void> resetApplicationBrightness() async {
    await ScreenBrightness.instance.resetApplicationScreenBrightness();
  }
}
