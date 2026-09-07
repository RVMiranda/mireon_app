import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mireon/features/profiles/data/datasources/profiles_local_data_source.dart';
import 'package:mireon/features/profiles/data/repositories/secure_profiles_repository.dart';
import 'package:mireon/features/profiles/domain/repositories/profiles_repository.dart';
import 'package:mireon/features/profiles/domain/use_cases/profile_operations.dart';
import 'package:mireon/features/profiles/presentation/view_models/profiles_notifier.dart';
import 'support/security_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MemorySecureStorage storage;
  late FakeHasher hasher;
  late DateTime now;
  late SecureProfilesRepository repository;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = MemorySecureStorage();
    hasher = FakeHasher();
    now = DateTime(2026);
    repository = SecureProfilesRepository(
      ProfilesLocalDataSource(storage),
      hasher,
      now: () => now,
    );
  });

  void legacy() {
    SharedPreferences.setMockInitialValues({
      'app_user_profiles_v1': jsonEncode([
        {
          'id': 'legacy-id',
          'name': 'Privado',
          'iconName': 'lock',
          'colorValue': 123,
          'hashedPin': 'old',
          'createdAt': '2025-01-01',
        },
      ]),
      'app_active_profile_id': 'legacy-id',
      'app_onboarding_completed': true,
      'unrelated_setting': true,
    });
  }

  test(
    'migration preserves identity and removes legacy data only after secure commit',
    () async {
      legacy();
      final snapshot = await repository.load();
      expect(snapshot.activeId, 'legacy-id');
      expect(snapshot.profiles.single.isProtected, isTrue);
      expect(snapshot.onboardingCompleted, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('app_user_profiles_v1'), isFalse);
      expect(prefs.getBool('unrelated_setting'), isTrue);
      expect(storage.values.values.single, contains('legacy:old'));
      expect(await repository.authenticate('legacy-id', '1234'), isTrue);
      expect(storage.values.values.single, contains('test:1234'));
      expect(storage.values.values.single, isNot(contains('legacy:old')));
    },
  );

  test(
    'failed migration preserves original and does not create an empty catalog',
    () async {
      legacy();
      storage.failWrites = true;
      await expectLater(repository.load(), throwsStateError);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('app_user_profiles_v1'), isTrue);
      expect(storage.values, isEmpty);
    },
  );

  test('corrupt profile storage fails closed', () async {
    SharedPreferences.setMockInitialValues({'app_user_profiles_v1': 'broken'});
    await expectLater(repository.load(), throwsFormatException);
    expect(storage.values, isEmpty);
  });

  test(
    'a missing secure catalog after migration does not reset protection',
    () async {
      legacy();
      await repository.load();
      storage.values.clear();
      await expectLater(repository.load(), throwsStateError);
    },
  );

  test('interrupted cleanup resumes from the committed secure catalog', () async {
    legacy();
    await repository.load();
    final committed = storage.values.values.single;
    legacy(); // Simulate a crash after secure write but before preferences cleanup.
    await repository.load();
    expect(storage.values.values.single, committed);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('app_user_profiles_v1'), isFalse);
    expect(prefs.getBool(ProfilesLocalDataSource.migrationMarker), isTrue);
  });

  test(
    'protected edit, credential removal and deletion require current secret',
    () async {
      final protected = await repository.create(
        name: 'Private',
        iconName: 'lock',
        colorValue: 0,
        secret: '123456',
      );
      await repository.create(
        name: 'Public',
        iconName: 'person',
        colorValue: 0,
      );
      await expectLater(
        repository.update(
          protected.id,
          name: 'Changed',
          iconName: 'lock',
          colorValue: 0,
          clearSecret: true,
        ),
        throwsA(isA<ProfileAccessException>()),
      );
      await expectLater(
        repository.delete(protected.id),
        throwsA(isA<ProfileAccessException>()),
      );
      final snapshot = await repository.load();
      expect(snapshot.profiles.first.name, 'Private');
      expect(snapshot.profiles.first.isProtected, isTrue);
    },
  );

  test('failed attempts survive repository recreation and expire', () async {
    final p = await repository.create(
      name: 'Private',
      iconName: 'lock',
      colorValue: 0,
      secret: '123456',
    );
    expect(await repository.authenticate(p.id, 'wrong'), isFalse);
    final reopened = SecureProfilesRepository(
      ProfilesLocalDataSource(storage),
      hasher,
      now: () => now,
    );
    await expectLater(
      reopened.authenticate(p.id, '123456'),
      throwsA(isA<ProfileAccessException>()),
    );
    now = now.add(const Duration(seconds: 2));
    expect(await reopened.authenticate(p.id, '123456'), isTrue);
  });

  test('simultaneous creates do not overwrite one another', () async {
    await Future.wait(
      List.generate(
        4,
        (i) => repository.create(
          name: 'Profile $i',
          iconName: 'person',
          colorValue: 0,
        ),
      ),
    );
    expect((await repository.load()).profiles.length, 4);
  });

  test('new credentials are validated before persistence', () async {
    final useCases = ProfileOperations(repository);
    expect(
      () => useCases.create(
        name: 'Private',
        iconName: 'lock',
        colorValue: 0,
        secret: '1234',
      ),
      throwsA(isA<ProfileAccessException>()),
    );
    expect((await repository.load()).profiles, isEmpty);
  });

  test(
    'restart locks active profile; background invalidates pending unlock',
    () async {
      final p = await repository.create(
        name: 'Private',
        iconName: 'lock',
        colorValue: 0,
        secret: '123456',
      );
      final notifier = ProfilesNotifier(ProfileOperations(repository));
      addTearDown(notifier.dispose);
      while (notifier.state.isLoading) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(notifier.state.isLocked, isTrue);
      expect(await notifier.setActiveProfile(p.id, pin: '123456'), isTrue);
      expect(notifier.state.isLocked, isFalse);
      notifier.lock();
      hasher.pendingVerification = Completer<void>();
      final unlock = notifier.setActiveProfile(p.id, pin: '123456');
      await Future<void>.delayed(Duration.zero);
      notifier.setForeground(false);
      notifier.setForeground(true);
      hasher.pendingVerification!.complete();
      await unlock;
      expect(notifier.state.isLocked, isTrue);
    },
  );
}
