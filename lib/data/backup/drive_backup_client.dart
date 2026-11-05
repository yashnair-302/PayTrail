import 'dart:typed_data';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;

/// Stores one encrypted backup file in the user's own Google Drive.
///
/// Three things make this safe to lean on for sync:
///
/// * **The app-data folder, not the user's Drive.** The only scope requested is
///   `drive.appdata`, which can see a hidden per-app folder and nothing else —
///   not the user's documents, not files other apps wrote. PayTrail is
///   technically incapable of reading the rest of their Drive.
/// * **The file is already ciphertext.** [BackupCrypto] seals the snapshot
///   before it ever reaches this class, so what lands in Drive is unreadable to
///   Google and to anyone who gets the file.
/// * **One account is the whole identity.** Signing in with the same Google
///   account on another device is how that device finds this file and pulls the
///   ledger down — no PayTrail account, no password to reset.
class DriveBackupClient {
  /// The narrowest Drive scope: an app-private folder, invisible elsewhere.
  static const List<String> scopes = <String>[drive.DriveApi.driveAppdataScope];

  /// Single, stable file name inside the app-data folder — a backup replaces the
  /// previous one rather than piling up copies.
  static const String fileName = 'paytrail-backup.enc';

  bool _initialised = false;

  /// Prepares Google Sign-In. [serverClientId] is the Web OAuth client id, which
  /// google_sign_in requires on Android. Safe to call repeatedly.
  Future<void> initialize({String? clientId, String? serverClientId}) async {
    if (_initialised) return;
    await GoogleSignIn.instance.initialize(
      clientId: clientId,
      serverClientId: serverClientId,
    );
    _initialised = true;
  }

  /// Prompts the user to sign in and grant the app-data scope. Returns the
  /// account email so the UI can show whose Drive holds the backup.
  Future<String?> connect() async {
    if (!_initialised) {
      throw StateError('DriveBackupClient.initialize must be called first.');
    }
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw UnsupportedError('Google sign-in is not available on this platform.');
    }

    final GoogleSignInAccount account =
        await GoogleSignIn.instance.authenticate(scopeHint: scopes);
    final GoogleSignInClientAuthorization authorization =
        await account.authorizationClient.authorizeScopes(scopes);
    // Surface a refused consent here, not at the first backup.
    authorization.authClient(scopes: scopes).close();
    return account.email;
  }

  Future<void> disconnect() async {
    if (!_initialised) return;
    await GoogleSignIn.instance.disconnect();
  }

  /// An authorized client if the scope is already granted, without prompting.
  Future<auth.AuthClient?> _client() async {
    final GoogleSignInAccount? account =
        await GoogleSignIn.instance.attemptLightweightAuthentication();
    if (account == null) return null;
    final GoogleSignInClientAuthorization? authorization =
        await account.authorizationClient.authorizationForScopes(scopes);
    if (authorization == null) return null;
    return authorization.authClient(scopes: scopes);
  }

  /// Uploads [bytes], replacing the existing backup if there is one.
  Future<void> upload(Uint8List bytes) async {
    final auth.AuthClient? client = await _client();
    if (client == null) {
      throw StateError('No Google account is connected for backup.');
    }
    try {
      final drive.DriveApi api = drive.DriveApi(client);
      final String? existingId = await _findFileId(api);
      final drive.Media media =
          drive.Media(Stream<List<int>>.value(bytes), bytes.length);

      if (existingId == null) {
        final drive.File metadata = drive.File()
          ..name = fileName
          ..parents = <String>['appDataFolder'];
        await api.files.create(metadata, uploadMedia: media);
      } else {
        await api.files.update(drive.File(), existingId, uploadMedia: media);
      }
    } finally {
      client.close();
    }
  }

  /// Downloads the backup, or null when none exists for this account yet.
  Future<Uint8List?> download() async {
    final auth.AuthClient? client = await _client();
    if (client == null) {
      throw StateError('No Google account is connected for backup.');
    }
    try {
      final drive.DriveApi api = drive.DriveApi(client);
      final String? id = await _findFileId(api);
      if (id == null) return null;

      final drive.Media media = await api.files.get(
        id,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final BytesBuilder builder = BytesBuilder();
      await for (final List<int> chunk in media.stream) {
        builder.add(chunk);
      }
      return builder.toBytes();
    } finally {
      client.close();
    }
  }

  Future<String?> _findFileId(drive.DriveApi api) async {
    final drive.FileList list = await api.files.list(
      spaces: 'appDataFolder',
      q: "name = '$fileName'",
      $fields: 'files(id,name)',
    );
    final List<drive.File>? files = list.files;
    if (files == null || files.isEmpty) return null;
    return files.first.id;
  }
}
