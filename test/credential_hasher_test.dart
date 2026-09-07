import 'package:flutter_test/flutter_test.dart';
import 'package:mireon/core/security/credential_hasher.dart';

void main() {
  test(
    'PBKDF2 uses unique salts and verifies only the matching credential',
    () async {
      const hasher = Pbkdf2CredentialHasher();
      final first = await hasher.hash('123456');
      final second = await hasher.hash('123456');
      expect(first, isNot(second));
      expect(first, startsWith('pbkdf2-sha256:600000:'));
      expect(await hasher.verify('123456', first), isTrue);
      expect(await hasher.verify('654321', first), isFalse);
      await expectLater(
        hasher.verify('123456', 'pbkdf2-sha256:1:AA==:AA=='),
        throwsFormatException,
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
