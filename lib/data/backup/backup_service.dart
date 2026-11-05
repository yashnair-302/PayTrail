import '../db/database.dart';
import 'backup_crypto.dart';
import 'drive_backup_client.dart';
import 'ledger_snapshot.dart';

/// The one entry point the UI uses for backup and sync.
///
/// It owns the sequence — export, encrypt, upload; and download, decrypt,
/// import — so no screen can get the order wrong, and so the plaintext snapshot
/// exists only for the moment between the database and the cipher, never on disk
/// and never in Drive.
class BackupService {
  BackupService(
    PayTrailDatabase database,
    this._drive, {
    this.serverClientId,
  }) : _codec = LedgerSnapshotCodec(database);

  final LedgerSnapshotCodec _codec;
  final DriveBackupClient _drive;

  /// The Web OAuth client id google_sign_in needs on Android.
  final String? serverClientId;

  /// Signs in and grants the Drive app-data scope. Returns the account email.
  Future<String?> connect() async {
    await _drive.initialize(serverClientId: serverClientId);
    return _drive.connect();
  }

  Future<void> disconnect() => _drive.disconnect();

  /// Exports the ledger, encrypts it under [passphrase], and uploads it.
  Future<void> backupNow(String passphrase) async {
    final Map<String, dynamic> snapshot = await _codec.export();
    final blob = await BackupCrypto.encryptJson(snapshot, passphrase);
    await _drive.upload(blob);
  }

  /// Downloads the backup, decrypts it under [passphrase], and replaces the
  /// local ledger with it. Returns false when the account has no backup yet.
  ///
  /// Throws [BackupPassphraseError] if the passphrase is wrong.
  Future<bool> restore(String passphrase) async {
    final blob = await _drive.download();
    if (blob == null) return false;
    final Map<String, dynamic> snapshot =
        await BackupCrypto.decryptJson(blob, passphrase);
    await _codec.import(snapshot);
    return true;
  }
}
