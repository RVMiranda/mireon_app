import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:crypto/crypto.dart' as legacy;
import 'package:cryptography/cryptography.dart';

abstract interface class CredentialHasher {
  Future<String> hash(String secret);
  Future<bool> verify(String secret, String encoded);
}

class Pbkdf2CredentialHasher implements CredentialHasher {
  const Pbkdf2CredentialHasher();
  static const iterations = 600000;
  @override
  Future<String> hash(String secret) => Isolate.run(() async {
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final key = await _derive(secret, salt);
    return 'pbkdf2-sha256:$iterations:${base64Encode(salt)}:${base64Encode(key)}';
  });
  @override
  Future<bool> verify(String secret, String encoded) => Isolate.run(() async {
    if (encoded.startsWith('legacy:')) {
      final actual = legacy.sha256
          .convert(utf8.encode('galery_app_secure_salt_$secret'))
          .toString();
      return _equal(utf8.encode(actual), utf8.encode(encoded.substring(7)));
    }
    final parts = encoded.split(':');
    if (parts.length != 4 ||
        parts[0] != 'pbkdf2-sha256' ||
        parts[1] != '$iterations') {
      throw const FormatException('Invalid credential record');
    }
    final salt = base64Decode(parts[2]);
    final expected = base64Decode(parts[3]);
    if (salt.length != 16 || expected.length != 32) {
      throw const FormatException('Invalid credential parameters');
    }
    return _equal(await _derive(secret, salt), expected);
  });
  static Future<List<int>> _derive(String secret, List<int> salt) async {
    final key = await Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    ).deriveKey(secretKey: SecretKey(utf8.encode(secret)), nonce: salt);
    return key.extractBytes();
  }

  static bool _equal(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }
    return difference == 0;
  }
}
