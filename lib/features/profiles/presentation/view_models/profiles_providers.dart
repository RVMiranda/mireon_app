import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/security/credential_hasher.dart';
import '../../../../core/security/platform_secure_storage_service.dart';
import '../../data/datasources/profiles_local_data_source.dart';
import '../../data/repositories/secure_profiles_repository.dart';
import '../../domain/repositories/profiles_repository.dart';
import '../../domain/use_cases/profile_operations.dart';
import 'profiles_notifier.dart';
import 'profiles_state.dart';
export 'profiles_notifier.dart';
export 'profiles_state.dart';

final profilesRepositoryProvider = Provider<ProfilesRepository>(
  (ref) => SecureProfilesRepository(
    const ProfilesLocalDataSource(PlatformSecureStorageService()),
    const Pbkdf2CredentialHasher(),
  ),
);

final profilesNotifierProvider =
    StateNotifierProvider<ProfilesNotifier, ProfilesState>(
      (ref) => ProfilesNotifier(
        ProfileOperations(ref.watch(profilesRepositoryProvider)),
      ),
    );
