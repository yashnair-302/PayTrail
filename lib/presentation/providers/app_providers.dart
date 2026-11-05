import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';

import '../../data/backup/backup_service.dart';
import '../../data/export/csv_exporter.dart';
import '../../data/export/invoice_pdf.dart';
import '../../data/ingest/fiverr_source.dart';
import '../../data/ingest/gmail_client.dart';
import '../../data/ingest/notification_listener.dart';
import '../../data/ingest/upwork_source.dart';
import '../../domain/calendar.dart';
import '../../domain/export/income_report.dart';
import '../../domain/ingest/payment_source_adapter.dart';
import '../../domain/reminders/reminder_rules.dart';
import '../../domain/repositories/ingest_repository.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/repositories/ledger_repository.dart';
import 'ledger_providers.dart';

/// Every platform the app can read.
///
/// The single registration point for Module 3: adding a marketplace means
/// writing one adapter and adding it to this list. Nothing else — not the
/// notification service, not the Gmail query, not the review queue — needs to
/// know the new platform exists.
final Provider<PaymentSourceRegistry> sourceRegistryProvider =
    Provider<PaymentSourceRegistry>(
  (Ref ref) => const PaymentSourceRegistry(<PaymentSourceAdapter>[
    FiverrSource(),
    UpworkSource(),
  ]),
);

/// Overridden in `main()`, like the ledger.
final Provider<IngestRepository> ingestRepositoryProvider =
    Provider<IngestRepository>(
  (Ref ref) => throw UnimplementedError(
    'ingestRepositoryProvider must be overridden in main().',
  ),
);

final Provider<ReminderRepository> reminderRepositoryProvider =
    Provider<ReminderRepository>(
  (Ref ref) => throw UnimplementedError(
    'reminderRepositoryProvider must be overridden in main().',
  ),
);

/// Overridden in `main()`: it needs the opened database, which lives there.
final Provider<BackupService> backupServiceProvider = Provider<BackupService>(
  (Ref ref) => throw UnimplementedError(
    'backupServiceProvider must be overridden in main().',
  ),
);

final Provider<NotificationCapture> notificationCaptureProvider =
    Provider<NotificationCapture>(
  (Ref ref) => NotificationCapture(ref.watch(sourceRegistryProvider)),
);

final Provider<GmailClient> gmailClientProvider = Provider<GmailClient>(
  (Ref ref) => GmailClient(ref.watch(sourceRegistryProvider)),
);

/// The Web OAuth client id from the Google Cloud console, passed to the Gmail
/// client as `serverClientId`. google_sign_in requires this on Android even
/// though app identity comes from the Android client's package + SHA-1. A client
/// id is public, not a secret, so keeping it here is fine; swapping projects is
/// a one-line change.
const String kGmailServerClientId =
    '607658769134-2ev7tmcplnn257g1kg3l4bl5i9lqh4qe.apps.googleusercontent.com';

final Provider<CsvExporter> csvExporterProvider =
    Provider<CsvExporter>((Ref ref) => const CsvExporter());

final Provider<InvoicePdf> invoicePdfProvider =
    Provider<InvoicePdf>((Ref ref) => const InvoicePdf());

// --- Ingestion -------------------------------------------------------------

final StreamProvider<List<IngestedEvent>> pendingIngestProvider =
    StreamProvider<List<IngestedEvent>>(
  (Ref ref) => ref.watch(ingestRepositoryProvider).watchPending(),
);

final StreamProvider<List<IngestedEvent>> ingestHistoryProvider =
    StreamProvider<List<IngestedEvent>>(
  (Ref ref) => ref.watch(ingestRepositoryProvider).watchAll(),
);

/// Whether the user has consented to a given channel.
final settingProvider = StreamProvider.family<String?, String>(
  (Ref ref, String key) =>
      ref.watch(ingestRepositoryProvider).watchSetting(key),
);

/// Convenience: a consent flag as a bool.
final consentProvider = Provider.family<bool, String>(
  (Ref ref, String key) =>
      ref.watch(settingProvider(key)).value == 'true',
);

// --- Appearance ------------------------------------------------------------

/// The app's theme preference, read live from settings so flipping it in
/// Settings repaints the whole app at once. Defaults to [ThemeMode.system].
final Provider<ThemeMode> themeModeProvider = Provider<ThemeMode>((Ref ref) {
  final String? raw = ref.watch(settingProvider(SettingKeys.themeMode)).value;
  return switch (raw) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
});

/// Persists a [ThemeMode] choice. Stored as a plain string so the setting is
/// readable and survives an export like every other preference.
Future<void> setThemeMode(WidgetRef ref, ThemeMode mode) {
  final String value = switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };
  return ref.read(ingestRepositoryProvider).setSetting(
        SettingKeys.themeMode,
        value,
      );
}

// --- Reminders -------------------------------------------------------------

final StreamProvider<List<ReminderLogEntry>> reminderLogProvider =
    StreamProvider<List<ReminderLogEntry>>(
  (Ref ref) => ref.watch(reminderRepositoryProvider).watchAll(),
);

final clientReminderLogProvider =
    StreamProvider.family<List<ReminderLogEntry>, String>(
  (Ref ref, String clientId) =>
      ref.watch(reminderRepositoryProvider).watchForClient(clientId),
);

/// The reminder queue: drafts waiting to be reviewed and sent.
///
/// Derived from the open milestones and the log, so recording a payment makes a
/// draft disappear and sending one suppresses it for a week — with no explicit
/// refresh anywhere.
final Provider<AsyncValue<List<ReminderDraft>>> reminderQueueProvider =
    Provider<AsyncValue<List<ReminderDraft>>>((Ref ref) {
  final AsyncValue<List<MilestoneWithContext>> open =
      ref.watch(openMilestonesProvider);
  final AsyncValue<List<ReminderLogEntry>> log = ref.watch(reminderLogProvider);
  final String senderName =
      ref.watch(settingProvider(SettingKeys.invoiceBusinessName)).value ??
          'Your name';

  if (open.hasError) {
    return AsyncValue<List<ReminderDraft>>.error(
      open.error!,
      open.stackTrace ?? StackTrace.current,
    );
  }
  if (log.hasError) {
    return AsyncValue<List<ReminderDraft>>.error(
      log.error!,
      log.stackTrace ?? StackTrace.current,
    );
  }

  final List<MilestoneWithContext>? openValue = open.value;
  final List<ReminderLogEntry>? logValue = log.value;
  if (openValue == null || logValue == null) {
    return const AsyncValue<List<ReminderDraft>>.loading();
  }

  return AsyncValue<List<ReminderDraft>>.data(
    buildReminderQueue(
      open: openValue,
      log: logValue,
      asOf: today(),
      senderName: senderName,
      // Formatting is injected so the domain stays free of locale data while
      // the drafts still read like a person wrote them.
      formatAmount: formatMoney,
      formatDate: formatDate,
    ),
  );
});

// --- Export ----------------------------------------------------------------

/// Every receipt in the ledger, with the context the exports need.
final StreamProvider<List<IncomeRow>> incomeRowsProvider =
    StreamProvider<List<IncomeRow>>(
  (Ref ref) => ref.watch(ledgerRepositoryProvider).watchIncomeRows(),
);
