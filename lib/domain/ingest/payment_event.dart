import '../entities/payment.dart';
import '../money.dart';

/// A payment the app learned about from somewhere other than the user typing
/// it in.
///
/// All three ingestion paths — statement upload, email, notification — produce
/// this one type. That is the point: parsing is per-platform and per-format,
/// but everything downstream (deduplication, matching, review, import) is
/// written once against [PaymentEvent] and does not care where the event came
/// from.
class PaymentEvent {
  const PaymentEvent({
    required this.sourceId,
    required this.channel,
    required this.grossAmount,
    required this.occurredAt,
    required this.raw,
    this.netAmount,
    this.externalTxnId,
    this.clientHint,
    this.projectHint,
    this.description,
  });

  /// Which payment channel produced it — `upwork`, `fiverr`, …
  final String sourceId;

  /// Which of the three paths it arrived by.
  final IngestSource channel;

  /// The headline figure the platform quoted.
  final Money grossAmount;

  /// What actually reaches the bank, when the source states it.
  ///
  /// Statements usually give both gross and net; a notification rarely gives
  /// more than one number. Null means "the platform did not say", and the
  /// importer falls back to the milestone's own commission rate rather than
  /// guessing here.
  final Money? netAmount;

  /// When the payment happened, as the source reported it.
  final DateTime occurredAt;

  /// The platform's transaction identifier, when there is one.
  ///
  /// The strongest half of the deduplication key. A notification usually has
  /// none, which is exactly why the key falls back to amount and date.
  final String? externalTxnId;

  /// Buyer or client name as the platform spells it, used to suggest a match.
  final String? clientHint;

  /// Order or contract id, matched against `Project.externalRef`.
  final String? projectHint;

  final String? description;

  /// The original line or message text.
  ///
  /// Kept verbatim so a mis-parse can be diagnosed from the record itself
  /// rather than by asking the user to re-download a statement.
  final String raw;

  /// What the importer should record as received.
  Money get amountToRecord => netAmount ?? grossAmount;

  String get currency => grossAmount.currency;

  /// The deduplication key: source + external id + amount + date.
  ///
  /// The same payout legitimately arrives three times — a notification when it
  /// clears, an email an hour later, a statement row at month end. Without a
  /// stable key across those three the ledger would triple-count it. The date
  /// is reduced to a calendar day because the three channels disagree about the
  /// exact timestamp of the same event.
  String get dedupeKey {
    final String id = externalTxnId?.trim().toLowerCase() ?? '';
    final String day = '${occurredAt.year.toString().padLeft(4, '0')}-'
        '${occurredAt.month.toString().padLeft(2, '0')}-'
        '${occurredAt.day.toString().padLeft(2, '0')}';
    return '$sourceId|$id|${grossAmount.currency}|'
        '${grossAmount.minorUnits}|$day';
  }

  PaymentEvent copyWith({
    Money? netAmount,
    String? externalTxnId,
    String? clientHint,
    String? projectHint,
    String? description,
  }) {
    return PaymentEvent(
      sourceId: sourceId,
      channel: channel,
      grossAmount: grossAmount,
      netAmount: netAmount ?? this.netAmount,
      occurredAt: occurredAt,
      externalTxnId: externalTxnId ?? this.externalTxnId,
      clientHint: clientHint ?? this.clientHint,
      projectHint: projectHint ?? this.projectHint,
      description: description ?? this.description,
      raw: raw,
    );
  }

  @override
  String toString() =>
      'PaymentEvent($sourceId, $grossAmount, $occurredAt, $externalTxnId)';
}

/// A problem encountered while parsing one row or message.
///
/// Parsing returns these alongside the events rather than throwing: one
/// malformed row in a 400-row Fiverr statement must not discard the other 399,
/// and the user needs to be told which rows were skipped and why.
class IngestIssue {
  const IngestIssue({
    required this.detail,
    this.lineNumber,
    this.raw,
  });

  final String detail;
  final int? lineNumber;
  final String? raw;

  @override
  String toString() =>
      lineNumber == null ? detail : 'Line $lineNumber: $detail';
}

/// The outcome of parsing one statement, mailbox page or notification.
class IngestResult {
  const IngestResult({required this.events, this.issues = const <IngestIssue>[]});

  const IngestResult.empty()
      : events = const <PaymentEvent>[],
        issues = const <IngestIssue>[];

  final List<PaymentEvent> events;
  final List<IngestIssue> issues;

  bool get hasIssues => issues.isNotEmpty;
  int get eventCount => events.length;
}

/// Where an ingested event has got to.
enum IngestStatus {
  /// Parsed and waiting for the user to confirm or dismiss it.
  pending,

  /// Confirmed by the user; a payment row exists for it.
  imported,

  /// Dismissed. Kept rather than deleted so the same event is not offered
  /// again the next time an overlapping statement is uploaded.
  ignored,
}
