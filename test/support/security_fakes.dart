import 'dart:async';
import 'package:mireon/core/security/credential_hasher.dart';
import 'package:mireon/core/security/secure_storage_service.dart';

class MemorySecureStorage implements SecureStorageService {
  final values = <String, String>{};
  bool failWrites = false;
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async {
    if (failWrites) throw StateError('Storage unavailable');
    values[key] = value;
  }
}

class FakeHasher implements CredentialHasher {
  Completer<void>? pendingVerification;
  @override
  Future<String> hash(String secret) async => 'test:$secret';
  @override
  Future<bool> verify(String secret, String encoded) async {
    await pendingVerification?.future;
    return encoded == 'test:$secret' ||
        (encoded == 'legacy:old' && secret == '1234');
  }
}
