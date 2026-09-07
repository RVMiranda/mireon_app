import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mireon/app/app.dart';
import 'package:mireon/features/profiles/data/datasources/profiles_local_data_source.dart';
import 'package:mireon/features/profiles/data/repositories/secure_profiles_repository.dart';
import 'package:mireon/features/profiles/presentation/view_models/profiles_providers.dart';
import 'support/security_fakes.dart';

void main() {
  testWidgets('app boots to home after loading an unprotected profile', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repository = SecureProfilesRepository(
      ProfilesLocalDataSource(MemorySecureStorage()),
      FakeHasher(),
    );
    await repository.create(name: 'Public', iconName: 'person', colorValue: 0);
    await repository.completeOnboarding();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [profilesRepositoryProvider.overrideWithValue(repository)],
        child: const MireonApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Inicio'), findsWidgets);
  });
}
