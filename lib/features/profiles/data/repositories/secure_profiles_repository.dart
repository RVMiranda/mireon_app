import 'dart:async';
import 'dart:math';
import '../../../../core/security/credential_hasher.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profiles_repository.dart';
import '../datasources/profiles_local_data_source.dart';

class SecureProfilesRepository implements ProfilesRepository {
  SecureProfilesRepository(this.source, this.hasher, {DateTime Function()? now})
    : _now = now ?? DateTime.now;
  final ProfilesLocalDataSource source;
  final CredentialHasher hasher;
  final DateTime Function() _now;
  Future<void> _tail = Future.value();

  Future<T> _serial<T>(Future<T> Function() action) {
    final result = _tail.then((_) => action());
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  List<Map<String, dynamic>> _entries(Map<String, dynamic> catalog) =>
      (catalog['profiles'] as List).cast<Map<String, dynamic>>();

  Map<String, dynamic> _entry(Map<String, dynamic> catalog, String id) =>
      _entries(catalog).firstWhere(
        (p) => p['id'] == id,
        orElse: () =>
            throw const ProfileAccessException('El perfil no existe.'),
      );

  UserProfile _profile(Map<String, dynamic> p) => UserProfile(
    id: p['id'] as String,
    name: p['name'] as String,
    iconName: p['iconName'] as String,
    colorValue: p['colorValue'] as int,
    createdAt: DateTime.parse(p['createdAt'] as String),
    isProtected: p['credential'] != null,
    allowedMediaIds: ((p['allowedMediaIds'] as List?) ?? const []).cast<String>().toSet(),
    allowedAlbumIds: ((p['allowedAlbumIds'] as List?) ?? const []).cast<String>().toSet(),
    hideFromGeneralLibrary: p['hideFromGeneralLibrary'] == true,
  );

  @override
  Future<ProfilesSnapshot> load() => _serial(() async {
    final catalog = await source.read();
    final profiles = _entries(catalog).map(_profile).toList();
    final active = catalog['activeId'] as String?;
    return ProfilesSnapshot(
      profiles: profiles,
      activeId: profiles.any((p) => p.id == active)
          ? active
          : (profiles.isEmpty ? null : profiles.first.id),
      onboardingCompleted: catalog['onboardingCompleted'] == true,
    );
  });

  Future<bool> _authenticate(
    Map<String, dynamic> catalog,
    Map<String, dynamic> entry,
    String? secret,
  ) async {
    final credential = entry['credential'] as String?;
    if (credential == null) return true;
    if (secret == null || secret.isEmpty) {
      throw const ProfileAccessException('Introduce la credencial actual.');
    }
    final now = _now().millisecondsSinceEpoch;
    final retryAt = entry['retryAt'] as int? ?? 0;
    if (now < retryAt) {
      throw ProfileAccessException(
        'Espera ${((retryAt - now) / 1000).ceil()} segundos antes de reintentar.',
      );
    }
    final attempts = (entry['attempts'] as int? ?? 0) + 1;
    entry['attempts'] = attempts;
    entry['retryAt'] = now + min(60, 1 << min(attempts - 1, 6)) * 1000;
    // Persist before verification: killing the app cannot reset the counter.
    await source.write(catalog);
    if (!await hasher.verify(secret, credential)) return false;
    if (credential.startsWith('legacy:')) {
      entry['credential'] = await hasher.hash(secret);
    }
    entry['attempts'] = 0;
    entry['retryAt'] = 0;
    await source.write(catalog);
    return true;
  }

  Future<void> _requireAuth(
    Map<String, dynamic> catalog,
    Map<String, dynamic> entry,
    String? secret,
  ) async {
    if (!await _authenticate(catalog, entry, secret)) {
      throw const ProfileAccessException('PIN o contraseña incorrecta.');
    }
  }

  @override
  Future<bool> authenticate(String id, String secret) => _serial(() async {
    final catalog = await source.read();
    return _authenticate(catalog, _entry(catalog, id), secret);
  });

  @override
  Future<UserProfile> create({
    required String name,
    required String iconName,
    required int colorValue,
    String? secret,
  }) => _serial(() async {
    final catalog = await source.read();
    final random = Random.secure();
    final id = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final entry = <String, dynamic>{
      'id': id,
      'name': name,
      'iconName': iconName,
      'colorValue': colorValue,
      'createdAt': _now().toIso8601String(),
      'credential': secret == null ? null : await hasher.hash(secret),
      'attempts': 0,
      'retryAt': 0,
      'allowedMediaIds': <String>[],
      'allowedAlbumIds': <String>[],
      'hideFromGeneralLibrary': false,
    };
    (catalog['profiles'] as List).add(entry);
    catalog['activeId'] ??= id;
    await source.write(catalog);
    return _profile(entry);
  });

  @override
  Future<void> update(
    String id, {
    required String name,
    required String iconName,
    required int colorValue,
    String? currentSecret,
    String? newSecret,
    bool clearSecret = false,
  }) => _serial(() async {
    final catalog = await source.read();
    final entry = _entry(catalog, id);
    await _requireAuth(catalog, entry, currentSecret);
    entry['name'] = name;
    entry['iconName'] = iconName;
    entry['colorValue'] = colorValue;
    if (clearSecret) {
      entry['credential'] = null;
    } else if (newSecret != null) {
      entry['credential'] = await hasher.hash(newSecret);
    }
    await source.write(catalog);
  });

  @override
  Future<void> delete(String id, {String? currentSecret}) => _serial(() async {
    final catalog = await source.read();
    final entry = _entry(catalog, id);
    await _requireAuth(catalog, entry, currentSecret);
    if (_entries(catalog).length <= 1) {
      throw const ProfileAccessException('Debes mantener al menos un perfil.');
    }
    (catalog['profiles'] as List).remove(entry);
    if (catalog['activeId'] == id) {
      catalog['activeId'] = _entries(catalog).first['id'];
    }
    await source.write(catalog);
  });

  @override
  Future<void> activate(String id, {String? secret}) => _serial(() async {
    final catalog = await source.read();
    await _requireAuth(catalog, _entry(catalog, id), secret);
    catalog['activeId'] = id;
    await source.write(catalog);
  });

  @override
  Future<void> completeOnboarding() => _serial(() async {
    final catalog = await source.read();
    if (_entries(catalog).isEmpty) {
      throw const ProfileAccessException('Crea un perfil para continuar.');
    }
    catalog['onboardingCompleted'] = true;
    await source.write(catalog);
  });
}
