import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profiles_repository.dart';
import '../../domain/use_cases/profile_operations.dart';
import 'profiles_state.dart';

class ProfilesNotifier extends StateNotifier<ProfilesState> {
  ProfilesNotifier(this.operations) : super(const ProfilesState()) {
    load();
  }
  final ProfileOperations operations;
  int _lockGeneration = 0;
  bool _foreground = true;

  Future<void> load() async {
    if (state.isBusy) return;
    state = state.copyWith(isLoading: true, lock: true);
    try {
      final snapshot = await operations.load();
      if (!mounted) return;
      state = state.copyWith(
        snapshot: snapshot,
        isLoading: false,
        loadFailed: false,
        lock: true,
      );
    } catch (_) {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          loadFailed: true,
          lock: true,
          errorMessage:
              'No se pudo acceder a los perfiles. Reintenta sin borrar los datos.',
        );
      }
    }
  }

  void setForeground(bool foreground) {
    _foreground = foreground;
    if (!foreground) lock();
  }

  void lock() {
    _lockGeneration++;
    if (mounted) state = state.copyWith(lock: true);
  }

  Future<T?> _run<T>(Future<T> Function() action, {String? unlockId}) async {
    if (state.isBusy || state.isLoading || state.loadFailed || !_foreground) {
      return null;
    }
    final generation = _lockGeneration;
    state = state.copyWith(isBusy: true);
    try {
      final result = await action();
      final snapshot = await operations.load();
      if (!mounted) return null;
      final canUnlock = generation == _lockGeneration && _foreground;
      state = state.copyWith(
        snapshot: snapshot,
        isBusy: false,
        unlockedProfileId: canUnlock ? unlockId : null,
        lock: !canUnlock,
      );
      return result;
    } on ProfileAccessException catch (error) {
      if (mounted) {
        state = state.copyWith(isBusy: false, errorMessage: error.message);
      }
    } catch (_) {
      if (mounted) {
        state = state.copyWith(
          isBusy: false,
          errorMessage: 'No se pudo completar la operación de perfiles.',
        );
      }
    }
    return null;
  }

  Future<bool> verifyPin(UserProfile profile, String rawPin) async =>
      await _run(() => operations.verify(profile.id, rawPin)) ?? false;

  Future<UserProfile?> createProfile({
    required String name,
    required String iconName,
    required int colorValue,
    String? pin,
  }) => _run(
    () => operations.create(
      name: name,
      iconName: iconName,
      colorValue: colorValue,
      secret: pin,
    ),
  );

  Future<bool> updateProfile(
    UserProfile target, {
    String? name,
    String? iconName,
    int? colorValue,
    String? currentPin,
    String? newPin,
    bool clearPin = false,
  }) async =>
      await _run(() async {
        await operations.update(
          target,
          name: name,
          iconName: iconName,
          colorValue: colorValue,
          currentSecret: currentPin,
          newSecret: newPin,
          clearSecret: clearPin,
        );
        return true;
      }) ??
      false;

  Future<bool> deleteProfile(String id, {String? currentPin}) async =>
      await _run(() async {
        await operations.delete(id, currentSecret: currentPin);
        return true;
      }) ??
      false;

  Future<bool> setActiveProfile(String id, {String? pin}) async =>
      await _run(() async {
        await operations.activate(id, secret: pin);
        return true;
      }, unlockId: id) ??
      false;

  Future<bool> completeOnboarding({
    required String name,
    required String iconName,
    required int colorValue,
    String? pin,
  }) async {
    return await _run(() async {
          final profile = await operations.create(
            name: name,
            iconName: iconName,
            colorValue: colorValue,
            secret: pin,
          );
          await operations.activate(profile.id, secret: pin);
          await operations.completeOnboarding();
          return true;
        }) ??
        false;
  }
}
