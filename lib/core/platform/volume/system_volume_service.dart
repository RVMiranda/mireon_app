import 'package:volume_controller/volume_controller.dart';

import 'volume_service.dart';

class SystemVolumeService implements VolumeService {
  SystemVolumeService({VolumeController? controller})
    : _controller = controller ?? VolumeController.instance {
    _controller.showSystemUI = false;
  }

  final VolumeController _controller;

  @override
  Future<double> getVolume() async {
    final v = await _controller.getVolume();
    return v.clamp(0.0, 1.0);
  }

  @override
  Future<void> setVolume(double value) async {
    final clamped = value.clamp(0.0, 1.0);
    await _controller.setVolume(clamped);
  }
}
