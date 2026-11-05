import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages the SQLCipher key for the ledger database.
///
/// The key is 32 random bytes generated on this device at first launch and kept
/// in the platform keystore (Android Keystore via `flutter_secure_storage`),
/// never in shared preferences and never in the source. It is passed to
/// SQLCipher as a *raw* key, so SQLCipher skips PBKDF2 key derivation — there
/// is no passphrase to stretch, and a full-entropy key gains nothing from it.
///
/// Consequence worth stating plainly in the report: the key lives and dies with
/// the app install. Uninstalling, or clearing app data, destroys it and the
/// database becomes permanently unreadable. That is the correct trade-off for a
/// local-only financial ledger with no account behind it, and it is why
/// Module 5's CSV export doubles as the backup story.
class DatabaseKeyStore {
  DatabaseKeyStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _storageKey = 'paytrail.db.cipher_key.v1';
  static const int _keyLengthBytes = 32; // 256-bit, SQLCipher's default.

  final FlutterSecureStorage _storage;

  /// Returns the existing key, generating and storing one on first run.
  ///
  /// The result is 64 lowercase hex characters, ready to be interpolated into
  /// `PRAGMA key = "x'...'"`.
  Future<String> loadOrCreate() async {
    final String? existing = await _storage.read(key: _storageKey);
    if (existing != null && _isValidRawKey(existing)) {
      return existing;
    }
    if (existing != null) {
      // A value is present but malformed — almost certainly a partially
      // written entry. Refuse rather than silently regenerate, because
      // regenerating would orphan an existing (readable) database file.
      throw StateError(
        'Stored database key is malformed. The ledger cannot be opened.',
      );
    }

    final String generated = _generateRawKey();
    await _storage.write(key: _storageKey, value: generated);
    return generated;
  }

  /// Whether a key has already been created on this device.
  Future<bool> hasKey() async =>
      await _storage.read(key: _storageKey) != null;

  static bool _isValidRawKey(String value) =>
      value.length == _keyLengthBytes * 2 &&
      RegExp(r'^[0-9a-f]+$').hasMatch(value);

  static String _generateRawKey() {
    // Random.secure() is backed by the platform CSPRNG. A non-secure Random
    // here would make the key predictable from the launch time, which defeats
    // the entire point of encrypting the file.
    final Random random = Random.secure();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < _keyLengthBytes; i++) {
      buffer.write(random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
