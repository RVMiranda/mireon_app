import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profiles_repository.dart';

class ProfilesState {
  const ProfilesState({
    this.profiles = const [],
    this.activeProfileId,
    this.isLoading = true,
    this.isBusy = false,
    this.errorMessage,
    this.loadFailed = false,
    this.onboardingCompleted = false,
    this.unlockedProfileId,
  });
  final List<UserProfile> profiles;
  final String? activeProfileId;
  final bool isLoading;
  final bool isBusy;
  final String? errorMessage;
  final bool loadFailed;
  final bool onboardingCompleted;
  final String? unlockedProfileId;

  UserProfile? get activeProfile {
    for (final p in profiles) {
      if (p.id == activeProfileId) return p;
    }
    return profiles.isEmpty ? null : profiles.first;
  }

  bool get isLocked =>
      activeProfile?.isProtected == true &&
      unlockedProfileId != activeProfile?.id;

  ProfilesState copyWith({
    ProfilesSnapshot? snapshot,
    bool? isLoading,
    bool? isBusy,
    String? errorMessage,
    bool? loadFailed,
    String? unlockedProfileId,
    bool lock = false,
  }) => ProfilesState(
    profiles: snapshot?.profiles ?? profiles,
    activeProfileId: snapshot == null ? activeProfileId : snapshot.activeId,
    onboardingCompleted: snapshot?.onboardingCompleted ?? onboardingCompleted,
    isLoading: isLoading ?? this.isLoading,
    isBusy: isBusy ?? this.isBusy,
    errorMessage: errorMessage,
    loadFailed: loadFailed ?? this.loadFailed,
    unlockedProfileId: lock
        ? null
        : (unlockedProfileId ?? this.unlockedProfileId),
  );
}
