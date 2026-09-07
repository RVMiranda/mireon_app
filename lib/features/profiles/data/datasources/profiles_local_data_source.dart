import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/security/secure_storage_service.dart';

class ProfilesLocalDataSource {
  const ProfilesLocalDataSource(this.storage);
  final SecureStorageService storage;
  static const secureKey = 'profiles_catalog_v2';
  static const migrationMarker = 'profiles_secure_migrated_v2';
  static const legacyKeys = [
    'app_user_profiles_v1',
    'app_active_profile_id',
    'app_onboarding_completed',
  ];
  Future<Map<String, dynamic>> read() async {
    final stored = await storage.read(secureKey);
    final prefs = await SharedPreferences.getInstance();
    if (stored != null) {
      final catalog = jsonDecode(stored) as Map<String, dynamic>;
      if (catalog['version'] != 2 || catalog['profiles'] is! List) {
        throw const FormatException('Invalid profile catalog');
      }
      if (!await prefs.setBool(migrationMarker, true)) {
        throw StateError('Migration marker could not be saved');
      }
      await _removeLegacy(prefs);
      return catalog;
    }
    if (prefs.getBool(migrationMarker) == true) {
      throw StateError('Secure profile catalog is missing');
    }
    final raw = prefs.getString(legacyKeys[0]);
    // Corrupt legacy data must fail closed, never silently reset profiles.
    final old = raw == null ? <dynamic>[] : jsonDecode(raw) as List<dynamic>;
    final profiles = old.map((value) {
      final entry = Map<String, dynamic>.from(value as Map);
      final hash = entry.remove('hashedPin') as String?;
      entry['credential'] = hash == null || hash.isEmpty
          ? null
          : 'legacy:$hash';
      entry['attempts'] = 0;
      entry['retryAt'] = 0;
      return entry;
    }).toList();
    final catalog = <String, dynamic>{
      'version': 2,
      'profiles': profiles,
      'activeId': prefs.getString(legacyKeys[1]),
      'onboardingCompleted': prefs.getBool(legacyKeys[2]) ?? false,
    };
    await write(catalog);
    if (!await prefs.setBool(migrationMarker, true)) {
      throw StateError('Migration marker could not be saved');
    }
    await _removeLegacy(prefs);
    return catalog;
  }

  Future<void> write(Map<String, dynamic> catalog) =>
      storage.write(secureKey, jsonEncode(catalog));
  Future<void> _removeLegacy(SharedPreferences prefs) async {
    for (final key in legacyKeys) {
      if (prefs.containsKey(key) && !await prefs.remove(key)) {
        throw StateError('Legacy profile cleanup failed');
      }
    }
  }
}
