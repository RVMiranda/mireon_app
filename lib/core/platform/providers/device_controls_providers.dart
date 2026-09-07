import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/audio_focus_service.dart';
import '../audio/audio_session_audio_focus_service.dart';
import '../brightness/brightness_service.dart';
import '../brightness/screen_brightness_service.dart';
import '../media/media_delete_service.dart';
import '../media/photo_manager_media_delete_service.dart';
import '../open_file/open_file_service.dart';
import '../open_file/open_filex_open_file_service.dart';
import '../share/share_plus_share_service.dart';
import '../share/share_service.dart';
import '../system_ui/flutter_system_ui_service.dart';
import '../system_ui/system_ui_service.dart';
import '../volume/system_volume_service.dart';
import '../volume/volume_service.dart';

final brightnessServiceProvider = Provider<BrightnessService>((ref) {
  return ScreenBrightnessService();
});

final volumeServiceProvider = Provider<VolumeService>((ref) {
  return SystemVolumeService();
});

final systemUiServiceProvider = Provider<SystemUiService>((ref) {
  return FlutterSystemUiService();
});

final audioFocusServiceProvider = Provider<AudioFocusService>((ref) {
  return AudioSessionAudioFocusService();
});

final shareServiceProvider = Provider<ShareService>((ref) {
  return SharePlusShareService();
});

final mediaDeleteServiceProvider = Provider<MediaDeleteService>((ref) {
  return PhotoManagerMediaDeleteService();
});

final openFileServiceProvider = Provider<OpenFileService>((ref) {
  return OpenFilexOpenFileService();
});
