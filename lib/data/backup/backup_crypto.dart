import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Thrown when a backup cannot be decrypted with the given passphrase.
///
/// Deliberately a distinct type so the UI can say "wrong passphrase" rather than
/// a raw crypto error — the two are indistinguishable to AES-GCM, which only
/// knows the authentication tag did not verify.
class BackupPassphraseError implements Exception {
  const BackupPassphraseError();

  @override
  String toString() =>
      'The recovery passphrase is wrong, or the backup file is corrupt.';
}

/// Encrypts and decrypts the ledger snapshot with a key derived from the user's
/// recovery passphrase.
///
/// The passphrase never leaves the device and is never stored: the key is
/// derived from it on the fly with PBKDF2 (a per-backup random salt, a high
/// iteration count), and the payload is sealed with AES-GCM so tampering or a
/// wrong key fails loudly instead of yielding garbage. This is what lets the
/// backup live in the user's Drive without Google — or anyone holding the file —
/// being able to read it. The flip side, stated plainly: lose the passphrase and
/// the backup is unrecoverable. That is the cost of end-to-end encryption, not a
/// bug to be worked around with a reset link.
class BackupCrypto {
  const BackupCrypto._();

  /// File signature: "PTB1". Lets a restore reject a file that is not a backup
  /// before it ever reaches the cipher.
  static const List<int> _magic = <int>[0x50, 0x54, 0x42, 0x31];
  static const int _saltLen = 16;
  static const int _nonceLen = 12;
  static const int _macLen = 16;

  /// PBKDF2 work factor. High enough to make guessing a weak passphrase slow,
  /// low enough to stay responsive on a mid-range phone.
  static const int _iterations = 150000;

  /// The shortest passphrase the UI should accept. Short enough not to nag,
  /// long enough that the KDF is defending something.
  static const int minPassphraseLength = 8;

  static final AesGcm _algorithm = AesGcm.with256bits();

  /// Serialises [json], encrypts it, and returns a self-describing blob:
  /// `magic | salt | nonce | mac | ciphertext`.
  static Future<Uint8List> encryptJson(
    Map<String, dynamic> json,
    String passphrase,
  ) async {
    final List<int> plain = utf8.encode(jsonEncode(json));
    final Uint8List salt = _randomBytes(_saltLen);
    final SecretKey key = await _deriveKey(passphrase, salt);
    final Uint8List nonce = _randomBytes(_nonceLen);

    final SecretBox box =
        await _algorithm.encrypt(plain, secretKey: key, nonce: nonce);

    final BytesBuilder out = BytesBuilder();
    out.add(_magic);
    out.add(salt);
    out.add(box.nonce);
    out.add(box.mac.bytes);
    out.add(box.cipherText);
    return out.toBytes();
  }

  /// Reverses [encryptJson]. Throws [BackupPassphraseError] when the passphrase
  /// is wrong or the file has been tampered with, and [FormatException] when the
  /// bytes are not a PayTrail backup at all.
  static Future<Map<String, dynamic>> decryptJson(
    Uint8List blob,
    String passphrase,
  ) async {
    final int headerLen = _magic.length + _saltLen + _nonceLen + _macLen;
    if (blob.length < headerLen) {
      throw const FormatException('This file is not a PayTrail backup.');
    }
    for (int i = 0; i < _magic.length; i++) {
      if (blob[i] != _magic[i]) {
        throw const FormatException('This file is not a PayTrail backup.');
      }
    }

    int offset = _magic.length;
    final Uint8List salt = blob.sublist(offset, offset + _saltLen);
    offset += _saltLen;
    final Uint8List nonce = blob.sublist(offset, offset + _nonceLen);
    offset += _nonceLen;
    final Uint8List mac = blob.sublist(offset, offset + _macLen);
    offset += _macLen;
    final Uint8List cipherText = blob.sublist(offset);

    final SecretKey key = await _deriveKey(passphrase, salt);
    final List<int> clear;
    try {
      clear = await _algorithm.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
        secretKey: key,
      );
    } on SecretBoxAuthenticationError {
      throw const BackupPassphraseError();
    }

    final Object? decoded = jsonDecode(utf8.decode(clear));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('The backup contents are not valid.');
    }
    return decoded;
  }

  static Future<SecretKey> _deriveKey(String passphrase, List<int> salt) {
    final Pbkdf2 pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _iterations,
      bits: 256,
    );
    return pbkdf2.deriveKeyFromPassword(password: passphrase, nonce: salt);
  }

  static Uint8List _randomBytes(int length) {
    final Random random = Random.secure();
    final Uint8List bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return bytes;
  }
}
