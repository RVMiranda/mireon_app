import '../entities/user_profile.dart';
import '../repositories/profiles_repository.dart';

/// Profile operations share validation; persistence and credentials stay behind
/// the repository boundary. No widget or provider is involved.
class ProfileOperations {
  const ProfileOperations(this.repository);
  final ProfilesRepository repository;
  Future<ProfilesSnapshot> load() => repository.load();
  Future<bool> verify(String id, String secret) =>
      repository.authenticate(id, secret);
  Future<void> activate(String id, {String? secret}) =>
      repository.activate(id, secret: secret);
  Future<void> completeOnboarding() => repository.completeOnboarding();

  Future<UserProfile> create({
    required String name,
    required String iconName,
    required int colorValue,
    String? secret,
  }) {
    _validateName(name);
    if (secret != null) _validateSecret(secret);
    return repository.create(
      name: name.trim(),
      iconName: iconName,
      colorValue: colorValue,
      secret: secret,
    );
  }

  Future<void> update(
    UserProfile profile, {
    String? name,
    String? iconName,
    int? colorValue,
    String? currentSecret,
    String? newSecret,
    bool clearSecret = false,
  }) {
    final nextName = name ?? profile.name;
    _validateName(nextName);
    if (newSecret != null) _validateSecret(newSecret);
    return repository.update(
      profile.id,
      name: nextName.trim(),
      iconName: iconName ?? profile.iconName,
      colorValue: colorValue ?? profile.colorValue,
      currentSecret: currentSecret,
      newSecret: newSecret,
      clearSecret: clearSecret,
    );
  }

  Future<void> delete(String id, {String? currentSecret}) =>
      repository.delete(id, currentSecret: currentSecret);

  void _validateName(String name) {
    if (name.trim().isEmpty || name.trim().length > 80) {
      throw const ProfileAccessException(
        'El nombre debe tener entre 1 y 80 caracteres.',
      );
    }
  }

  void _validateSecret(String secret) {
    final pin = RegExp(r'^\d{6,12}$').hasMatch(secret);
    final password = secret.length >= 10 && secret.length <= 128;
    if (!pin && !password) {
      throw const ProfileAccessException(
        'Usa un PIN de 6 a 12 dígitos o una contraseña de 10 a 128 caracteres.',
      );
    }
  }
}
