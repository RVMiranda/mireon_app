import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mireon/features/profiles/data/datasources/profiles_local_data_source.dart';
import 'package:mireon/features/profiles/data/repositories/secure_profiles_repository.dart';
import 'package:mireon/features/profiles/presentation/profile_security_gate.dart';
import 'package:mireon/features/profiles/presentation/view_models/profiles_providers.dart';
import 'support/security_fakes.dart';

void main() {
  testWidgets(
    'gate never builds protected content before unlock and removes it on background',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repository = SecureProfilesRepository(
        ProfilesLocalDataSource(MemorySecureStorage()),
        FakeHasher(),
      );
      await repository.create(
        name: 'Private',
        iconName: 'lock',
        colorValue: 0,
        secret: '123456',
      );
      var contentBuilds = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [profilesRepositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(
            home: ProfileSecurityGate(
              child: Builder(
                builder: (_) {
                  contentBuilds++;
                  return const Scaffold(body: Text('Sensitive content'));
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(contentBuilds, 0);
      expect(find.text('Sensitive content'), findsNothing);
      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.text('Desbloquear'));
      await tester.pumpAndSettle();
      expect(find.text('Sensitive content'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pumpAndSettle();
      expect(find.text('Sensitive content'), findsNothing);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('Sensitive content'), findsNothing);
      expect(find.text('Desbloquear'), findsOneWidget);
    },
  );
}
