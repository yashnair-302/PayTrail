import '../entities/payment.dart';
import '../ingest/payment_event.dart';
import '../money.dart';

/// A parsed event as it sits in the review queue.
class IngestedEvent {
  const IngestedEvent({
    required this.id,
    required this.event,
    required this.status,
    required this.createdAt,
    this.matchedMilestoneId,
    this.importedPaymentId,
    this.resolvedAt,
  });

  final String id;
  final PaymentEvent event;
  final IngestStatus status;
  final DateTime createdAt;

  /// Set once the user attaches it to a milestone.
  final String? matchedMilestoneId;
  final String? importedPaymentId;
  final DateTime? resolvedAt;

  bool get isPending => status == IngestStatus.pending;
}

/// What happened when a batch of parsed events was staged.
class IntakeSummary {
  const IntakeSummary({
    required this.staged,
    required this.duplicatesSkipped,
    required this.issues,
  });

  /// Newly queued for review.
  final int staged;

  /// Recognised as already seen — the point of the exercise.
  final int duplicatesSkipped;

  /// Rows or messages that could not be parsed.
  final List<IngestIssue> issues;

  bool get foundNothing => staged == 0 && duplicatesSkipped == 0;
}

/// Storage for the ingestion queue and the app-level settings that govern it.
///
/// Separate from `LedgerRepository` on purpose: the ledger is the record of
/// truth and this is a staging area in front of it. Keeping them apart makes it
/// structurally obvious that parsing cannot write a payment — importing goes
/// through [importEvent], which is the only path from one to the other.
abstract interface class IngestRepository {
  /// Screens [events] for duplicates and queues what is new.
  ///
  /// Deduplication happens here rather than in the caller so that every
  /// ingestion path — statement, email, notification — is screened by the same
  /// code with the same key.
  Future<IntakeSummary> stage(
    List<PaymentEvent> events, {
    List<IngestIssue> issues = const <IngestIssue>[],
  });

  /// Events awaiting review, newest payment first.
  Stream<List<IngestedEvent>> watchPending();

  /// Everything ever ingested, for the audit view.
  Stream<List<IngestedEvent>> watchAll({int limit = 200});

  Future<IngestedEvent?> getEvent(String id);

  /// Every dedupe key the app has seen, whatever its status.
  ///
  /// Includes ignored events: dismissing a row means "not this one", and
  /// re-offering it on the next overlapping upload would make dismissal
  /// useless.
  Future<Set<String>> knownDedupeKeys();

  /// Confirms an event: writes the payment and marks the event imported.
  ///
  /// One transaction, so an event can never be marked imported without its
  /// payment existing, nor a payment exist without the event being closed.
  Future<String> importEvent({
    required String eventId,
    required String milestoneId,
    required Money amount,
    required DateTime receivedAt,
    PaymentMethod method = PaymentMethod.platform,
    String? note,
  });

  /// Dismisses an event without importing it.
  Future<void> ignoreEvent(String eventId);

  /// Moves an imported or ignored event back into the queue.
  Future<void> reopenEvent(String eventId);

  Future<void> deleteEvent(String eventId);

  // --- Settings ------------------------------------------------------------

  Future<String?> getSetting(String key);
  Stream<String?> watchSetting(String key);
  Future<void> setSetting(String key, String value);
  Future<void> clearSetting(String key);
}

/// Setting keys. Constants rather than loose strings so a typo is a compile
/// error rather than a silently-forgotten consent flag.
abstract final class SettingKeys {
  /// Per-source consent, e.g. `consent.email`, `consent.notifications`.
  static String consent(String channel) => 'consent.$channel';

  static const String consentEmail = 'consent.email';
  static const String consentNotifications = 'consent.notifications';
  static const String consentStatements = 'consent.statements';

  /// ISO timestamp of the last successful mailbox read.
  static const String gmailLastSyncedAt = 'gmail.last_synced_at';

  /// The Google account the user connected, shown so they can see whose
  /// mailbox is being read.
  static const String gmailAccount = 'gmail.account';

  /// Extra email senders the user has added — bare domains (`razorpay.com`) or
  /// full addresses (`accounts@client.com`), newline-separated. Folded into the
  /// Gmail query alongside the built-in platform domains and parsed by a generic
  /// amount/date extractor; like every other source, what it finds still waits
  /// in the review queue for the user to confirm.
  static const String customEmailSenders = 'ingest.custom_senders';

  /// The Google account whose Drive holds the encrypted backup, shown so the
  /// user can see where their ledger is synced.
  static const String backupAccount = 'backup.account';

  /// ISO timestamp of the last successful backup.
  static const String backupLastAt = 'backup.last_at';

  /// The app's theme preference: `system` (default), `light` or `dark`.
  static const String themeMode = 'app.theme_mode';

  /// Business details used on generated invoices (Module 5).
  static const String invoiceBusinessName = 'invoice.business_name';
  static const String invoiceAddress = 'invoice.address';
  static const String invoiceEmail = 'invoice.email';
  static const String invoicePhone = 'invoice.phone';
  static const String invoiceTaxId = 'invoice.tax_id';
  static const String invoiceNumberPrefix = 'invoice.number_prefix';
  static const String invoiceNotes = 'invoice.notes';
}
