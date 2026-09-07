import 'package:flutter/foundation.dart';

import '../../../../core/platform/system_ui/system_ui_service.dart';
import 'media_viewer_state.dart';

class MediaViewerController extends ValueNotifier<MediaViewerState> {
  MediaViewerController({required int initialIndex})
    : super(
        MediaViewerState(
          currentIndex: initialIndex,
          controlsVisible: true,
          isFullscreen: false,
          orientationLock: AppOrientationLock.system,
        ),
      );

  void setCurrentIndex(int index) {
    value = value.copyWith(currentIndex: index);
  }

  void toggleControls() {
    value = value.copyWith(controlsVisible: !value.controlsVisible);
  }

  void showControls() {
    if (!value.controlsVisible) {
      value = value.copyWith(controlsVisible: true);
    }
  }

  void toggleFullscreen() {
    value = value.copyWith(isFullscreen: !value.isFullscreen);
  }

  void cycleOrientationLock() {
    final next = switch (value.orientationLock) {
      AppOrientationLock.system => AppOrientationLock.landscape,
      AppOrientationLock.landscape => AppOrientationLock.portrait,
      AppOrientationLock.portrait => AppOrientationLock.system,
    };

    value = value.copyWith(orientationLock: next);
  }
}
