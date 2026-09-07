import '../entities/user_profile.dart';

class ProfilesSnapshot {
  ProfilesSnapshot({
    required List<UserProfile> profiles,
    this.activeId,
    required this.onboardingCompleted,
  }) : profiles = List.unmodifiable(profiles);
  final List<UserProfile> profiles;
  final String? activeId;
  final bool onboardingCompleted;
}

abstract interface class ProfilesRepository {
  Future<ProfilesSnapshot> load();
  Future<bool> authenticate(String id, String secret);
  Future<UserProfile> create({
    required String name,
    required String iconName,
    required int colorValue,
    String? secret,
  });
  Future<void> update(
    String id, {
    required String name,
    required String iconName,
    required int colorValue,
    String? currentSecret,
    String? newSecret,
    bool clearSecret = false,
  });
  Future<void> delete(String id, {String? currentSecret});
  Future<void> activate(String id, {String? secret});
  Future<void> completeOnboarding();
}

class ProfileAccessException implements Exception {
  const ProfileAccessException(this.message);
  final String message;
}
