import '../../../../core/platform/system_ui/system_ui_service.dart';

class MediaViewerState {
  const MediaViewerState({
    required this.currentIndex,
    required this.controlsVisible,
    required this.isFullscreen,
    required this.orientationLock,
  });

  final int currentIndex;
  final bool controlsVisible;
  final bool isFullscreen;
  final AppOrientationLock orientationLock;

  MediaViewerState copyWith({
    int? currentIndex,
    bool? controlsVisible,
    bool? isFullscreen,
    AppOrientationLock? orientationLock,
  }) {
    return MediaViewerState(
      currentIndex: currentIndex ?? this.currentIndex,
      controlsVisible: controlsVisible ?? this.controlsVisible,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      orientationLock: orientationLock ?? this.orientationLock,
    );
  }
}
