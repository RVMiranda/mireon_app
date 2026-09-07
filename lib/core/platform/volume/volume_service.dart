abstract interface class VolumeService {
  /// Returns system volume in the range [0.0, 1.0].
  Future<double> getVolume();

  /// Sets system volume in the range [0.0, 1.0].
  Future<void> setVolume(double value);
}
