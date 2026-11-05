import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3_lib;

// Imported so the generated part file can see the enums used by textEnum
// columns in tables.dart; a part file does not inherit its sibling's imports.
import '../../domain/entities/milestone.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_source.dart';
import '../../domain/ingest/payment_event.dart';
import '../../domain/reminders/reminder_rules.dart';
import 'database_key.dart';
import 'tables.dart';

part 'database.g.dart';

/// The encrypted local ledger.
///
/// Everything in Modules 1–5 reads and writes through this one database. It is
/// opened with SQLCipher (configured in `pubspec.yaml` under
/// `hooks.user_defines.sqlite3`), so the file on disk is ciphertext from the
/// very first write — there is no unencrypted phase to migrate away from later.
@DriftDatabase(
  tables: <Type>[
    PaymentSources,
    Clients,
    Projects,
    Milestones,
    Payments,
    IngestEvents,
    AppSettings,
    ReminderLog,
  ],
)
class PayTrailDatabase extends _$PayTrailDatabase {
  PayTrailDatabase(super.e);

  /// Opens the on-device ledger, creating and encrypting it on first run.
  static Future<PayTrailDatabase> open({DatabaseKeyStore? keyStore}) async {
    final DatabaseKeyStore keys = keyStore ?? DatabaseKeyStore();
    final String rawKey = await keys.loadOrCreate();
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File(p.join(dir.path, 'paytrail.sqlite'));

    return PayTrailDatabase(
      NativeDatabase.createInBackground(
        file,
        setup: (sqlite3_lib.Database db) => _configure(db, rawKey),
      ),
    );
  }

  /// An unencrypted in-memory database, for tests.
  ///
  /// Encryption is a property of the file on disk; skipping it here keeps the
  /// domain and repository tests fast and free of platform channels, which a
  /// keystore lookup would otherwise require.
  static PayTrailDatabase inMemory() {
    return PayTrailDatabase(
      NativeDatabase.memory(
        setup: (sqlite3_lib.Database db) =>
            db.execute('PRAGMA foreign_keys = ON;'),
      ),
    );
  }

  /// Runs on the database isolate, before drift issues any statement.
  ///
  /// Order matters: the key must be applied before anything touches the file,
  /// otherwise SQLCipher sees an unreadable header and reports the database as
  /// corrupt.
  static void _configure(sqlite3_lib.Database db, String rawKey) {
    // Raw key form: the x'...' literal tells SQLCipher these are the key bytes
    // themselves, not a passphrase to run through PBKDF2.
    db.execute('PRAGMA key = "x\'$rawKey\'";');

    // Fail loudly if the build is not actually linked against SQLCipher.
    // Without this check a misconfigured build would silently fall back to
    // plain SQLite and write the entire ledger in the clear, which is exactly
    // the kind of failure that is invisible until it matters.
    final sqlite3_lib.ResultSet cipher = db.select('PRAGMA cipher_version;');
    if (cipher.isEmpty || '${cipher.first.values.first}'.isEmpty) {
      throw StateError(
        'SQLCipher is not available: the ledger would be stored unencrypted. '
        'Check hooks.user_defines.sqlite3.source in pubspec.yaml.',
      );
    }

    // Touch the database so a wrong key fails here, with a clear message,
    // rather than at some arbitrary later query.
    db.execute('SELECT count(*) FROM sqlite_master;');

    db.execute('PRAGMA foreign_keys = ON;');
    // WAL keeps reads from blocking on the write isolate — noticeable on the
    // dashboard, which runs several aggregate queries at once.
    db.execute('PRAGMA journal_mode = WAL;');
  }

  /// 1 — the core ledger (Module 1).
  /// 2 — the ingestion queue and app settings (Module 3).
  /// 3 — the reminder log (Module 4).
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Additive only. The Module 1 tables hold the user's income history;
          // a later module gaining a feature must never rewrite them.
          if (from < 2) {
            await m.createTable(ingestEvents);
            await m.createTable(appSettings);
          }
          if (from < 3) {
            await m.createTable(reminderLog);
          }
        },
        beforeOpen: (OpeningDetails details) async {
          // Foreign keys are per-connection, and drift may open its own; assert
          // them here as well as in _configure.
          await customStatement('PRAGMA foreign_keys = ON');
          await _seedBuiltInSources();
        },
      );

  /// Inserts any built-in source that is missing, leaving existing rows alone.
  ///
  /// Runs on every open rather than only on create, so a later release can add
  /// a fifth built-in platform without needing a schema migration. `insertOrIgnore`
  /// is the important part: it must never overwrite a commission rate the user
  /// has edited in Settings.
  Future<void> _seedBuiltInSources() async {
    final DateTime now = DateTime.now();
    await batch((Batch batch) {
      batch.insertAll(
        paymentSources,
        <PaymentSourcesCompanion>[
          for (final PaymentSource source in kBuiltInSources)
            PaymentSourcesCompanion.insert(
              id: source.id,
              displayName: source.displayName,
              commissionRateBps: Value<int>(source.commissionRateBps),
              defaultTdsRateBps: Value<int>(source.defaultTdsRateBps),
              isBuiltIn: const Value<bool>(true),
              sortOrder: Value<int>(source.sortOrder),
              createdAt: now,
              updatedAt: now,
            ),
        ],
        mode: InsertMode.insertOrIgnore,
      );
    });
  }
}
