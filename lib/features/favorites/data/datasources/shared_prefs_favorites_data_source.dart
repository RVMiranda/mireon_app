import 'package:shared_preferences/shared_preferences.dart';

import 'favorites_data_source.dart';

class SharedPrefsFavoritesDataSource implements FavoritesDataSource {
  static const _legacyKey = 'favorites.mediaIds';

  String _getKey(String? profileId) {
    if (profileId == null || profileId.trim().isEmpty) {
      return 'favorites.mediaIds.default';
    }
    return 'favorites.mediaIds.${profileId.trim()}';
  }

  @override
  Future<Set<String>> load({String? profileId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(profileId);

    if (!prefs.containsKey(key)) {
      final legacy = prefs.getStringList(_legacyKey);
      if (legacy != null && legacy.isNotEmpty) {
        await prefs.setStringList(key, legacy);
        return legacy.toSet();
      }
    }

    final list = prefs.getStringList(key) ?? const <String>[];
    return list.toSet();
  }

  @override
  Future<void> save(Set<String> ids, {String? profileId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(profileId);
    final list = ids.toList()..sort();
    await prefs.setStringList(key, list);
  }
}
