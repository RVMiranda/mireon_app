abstract interface class BrightnessService {
  /// Returns current application brightness in the range [0.0, 1.0].
  Future<double> getApplicationBrightness();

  /// Sets application brightness in the range [0.0, 1.0].
  Future<void> setApplicationBrightness(double value);

  /// Resets application brightness to the system/default value.
  Future<void> resetApplicationBrightness();
}
