import 'package:shared_preferences/shared_preferences.dart';
import '../domain/viewer_preferences_repository.dart';

class SharedPrefsViewerPreferences implements ViewerPreferencesRepository {
  Future<bool>? _claim;
  @override
  Future<bool> claimVideoGuide() async {
    if (_claim != null) {
      await _claim;
      return false;
    }
    _claim = _claimOnce();
    return _claim!;
  }

  Future<bool> _claimOnce() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('has_seen_video_guide') ?? false) return false;
    await prefs.setBool('has_seen_video_guide', true);
    return true;
  }
}
