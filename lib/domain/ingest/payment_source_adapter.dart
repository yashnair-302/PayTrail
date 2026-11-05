import 'payment_event.dart';

/// A message retrieved from the mailbox, reduced to what a parser needs.
///
/// Deliberately not a `googleapis` type: the parsers are pure Dart and unit
/// tested against hand-written fixtures, and nothing in the domain layer should
/// need a Gmail client to compile.
class EmailMessage {
  const EmailMessage({
    required this.id,
    required this.fromAddress,
    required this.subject,
    required this.body,
    required this.receivedAt,
  });

  final String id;

  /// The bare address, lowercased — `no-reply@fiverr.com`, not
  /// `"Fiverr" <no-reply@fiverr.com>`.
  final String fromAddress;

  final String subject;

  /// Plain-text body, HTML already stripped.
  final String body;

  final DateTime receivedAt;

  /// The part after the `@`, lowercased.
  String get senderDomain {
    final int at = fromAddress.lastIndexOf('@');
    if (at < 0 || at == fromAddress.length - 1) return '';
    return fromAddress.substring(at + 1).toLowerCase();
  }
}

/// An Android notification, reduced to what a parser needs.
class NotificationData {
  const NotificationData({
    required this.packageName,
    required this.title,
    required this.text,
    required this.postedAt,
  });

  final String packageName;
  final String title;
  final String text;
  final DateTime postedAt;
}

/// One platform's knowledge of itself: its rates, its addresses, its formats.
///
/// This is the extension point the whole of Module 3 hangs on. Adding Toptal or
/// PeoplePerHour later means writing one class that implements this interface
/// and registering it — no change to the deduplicator, the review queue, the
/// importer, or any screen. The three `parse*` methods mirror the three
/// ingestion paths and all return the same [PaymentEvent], so the paths stay
/// interchangeable downstream.
///
/// Named `PaymentSourceAdapter` rather than `PaymentSource` because that name
/// belongs to the configurable ledger entity; this is the code that knows how
/// to read one, and the two are deliberately separate — a user can change
/// Fiverr's commission rate without touching its parser.
abstract interface class PaymentSourceAdapter {
  /// Matches `PaymentSource.id`, so parsed events attach to the right channel.
  String get sourceId;

  String get displayName;

  /// The platform's standard commission, used when a statement reports gross
  /// only. The user's configured rate still wins for ledger arithmetic; this is
  /// a parsing fallback, not a source of truth.
  int get commissionRateBps;

  /// Sender domains this adapter will read email from.
  ///
  /// Enforced as an allowlist *before* any parsing, so a message from anywhere
  /// else is never even looked at. This is the concrete meaning of the promise
  /// that the app does not touch mail outside the platforms.
  Set<String> get emailSenderDomains;

  /// Android package names whose notifications this adapter understands.
  Set<String> get notificationPackages;

  /// Parses a downloaded CSV statement.
  ///
  /// Takes the file's text rather than a `File` so the parser is testable from
  /// a string fixture and has no filesystem dependency.
  IngestResult parseStatement(String csvContent);

  /// Parses one email, or returns null if it is not a payment notice.
  ///
  /// Implementations must re-check the sender domain themselves: defence in
  /// depth, so a bug in the caller's filter cannot turn into reading a personal
  /// email.
  PaymentEvent? parseEmail(EmailMessage message);

  /// Parses one notification, or returns null if it is not about a payment.
  PaymentEvent? parseNotification(NotificationData notification);
}

/// The adapters the app knows about, looked up by source id or by origin.
class PaymentSourceRegistry {
  const PaymentSourceRegistry(this.adapters);

  final List<PaymentSourceAdapter> adapters;

  PaymentSourceAdapter? bySourceId(String sourceId) =>
      adapters.where((PaymentSourceAdapter a) => a.sourceId == sourceId).firstOrNull;

  /// The adapter that claims [domain], or null if no platform owns it.
  PaymentSourceAdapter? byEmailDomain(String domain) {
    final String needle = domain.toLowerCase();
    return adapters
        .where((PaymentSourceAdapter a) => a.emailSenderDomains.contains(needle))
        .firstOrNull;
  }

  PaymentSourceAdapter? byNotificationPackage(String packageName) => adapters
      .where((PaymentSourceAdapter a) =>
          a.notificationPackages.contains(packageName))
      .firstOrNull;

  /// Every sender domain the app is willing to read, across all adapters.
  ///
  /// The Gmail query is built from exactly this set, so the request sent to
  /// Google is already narrowed to platform mail before a single message comes
  /// back.
  Set<String> get allEmailDomains => <String>{
        for (final PaymentSourceAdapter adapter in adapters)
          ...adapter.emailSenderDomains,
      };

  Set<String> get allNotificationPackages => <String>{
        for (final PaymentSourceAdapter adapter in adapters)
          ...adapter.notificationPackages,
      };
}
