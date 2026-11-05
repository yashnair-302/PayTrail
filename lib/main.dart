import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/backup/backup_service.dart';
import 'data/backup/drive_backup_client.dart';
import 'data/db/database.dart';
import 'data/repositories/drift_ingest_repository.dart';
import 'data/repositories/drift_ledger_repository.dart';
import 'data/repositories/drift_reminder_repository.dart';
import 'domain/repositories/ingest_repository.dart';
import 'domain/repositories/ledger_repository.dart';
import 'domain/repositories/reminder_repository.dart';
import 'presentation/providers/app_providers.dart';
import 'presentation/providers/ledger_providers.dart';

Future<void> main() async {
  // Required before touching the keystore: flutter_secure_storage goes over a
  // platform channel, and that channel does not exist until the binding is up.
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final PayTrailDatabase database = await PayTrailDatabase.open();

    final LedgerRepository ledger = DriftLedgerRepository(database);
    // The ingest repository writes payments through the ledger rather than
    // straight to the table, so reconciliation happens in exactly one place.
    final IngestRepository ingest = DriftIngestRepository(database, ledger);
    final ReminderRepository reminders = DriftReminderRepository(database);
    // Backup/sync is end-to-end encrypted against the user's own Drive; it needs
    // the opened database, so it is built here and injected like the rest.
    final BackupService backup = BackupService(
      database,
      DriveBackupClient(),
      serverClientId: kGmailServerClientId,
    );

    runApp(
      ProviderScope(
        overrides: [
          ledgerRepositoryProvider.overrideWithValue(ledger),
          ingestRepositoryProvider.overrideWithValue(ingest),
          reminderRepositoryProvider.overrideWithValue(reminders),
          backupServiceProvider.overrideWithValue(backup),
        ],
        child: const PayTrailApp(),
      ),
    );
  } catch (error) {
    // Opening the encrypted database is the one thing that must work before
    // anything is worth showing. Failing here with a readable message beats a
    // provider that throws on every screen.
    runApp(StartupFailureApp(error: error));
  }
}
