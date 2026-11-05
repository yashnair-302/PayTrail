import '../money.dart';

/// How a payment record entered the ledger.
///
/// Module 1 only ever writes [manual], but the column exists from the first
/// migration because Module 3's three ingestion paths all land in this same
/// table. Recording the path is what makes an automatic match auditable: when a
/// total looks wrong, the user can see which row the notification listener
/// guessed at and which one they typed themselves.
enum IngestSource {
  /// Entered by hand through the mark-as-paid flow.
  manual,

  /// Parsed from an uploaded Fiverr/Upwork CSV statement.
  statement,

  /// Extracted from a platform email over Gmail read-only.
  email,

  /// Captured on-device by the Android notification listener.
  notification,
}

/// How the money actually moved.
enum PaymentMethod { platform, bankTransfer, upi, cheque, cash, other }

/// One receipt against one milestone.
///
/// Payments are a separate table rather than a `paidAmount` column on the
/// milestone because part payments are the normal case in freelancing — 50%
/// advance, 50% on delivery, and a client who pays the balance in two
/// instalments. Storing each receipt keeps the dates, references and
/// provenance that a running total would throw away, and makes the tax export
/// a straight read of this table.
class Payment {
  const Payment({
    required this.id,
    required this.milestoneId,
    required this.amount,
    required this.receivedAt,
    required this.method,
    required this.ingestSource,
    required this.createdAt,
    this.reference,
    this.externalTxnId,
    this.note,
  });

  final String id;
  final String milestoneId;

  /// Amount actually received, net of whatever the platform already withheld.
  ///
  /// Recorded net rather than gross so that the sum of payments is directly
  /// comparable with [Milestone.netAmount] and, ultimately, with the bank
  /// statement.
  final Money amount;

  /// Calendar date the money was received.
  final DateTime receivedAt;

  final PaymentMethod method;

  /// User-facing reference: a UTR number, a cheque number, an invoice line.
  final String? reference;

  /// The platform's transaction id, when one is known.
  ///
  /// Part of Module 3's deduplication key (source + external id + amount +
  /// date): the same payment can legitimately arrive as a notification, then an
  /// email, then a statement row, and only this id distinguishes "seen three
  /// times" from "paid three times".
  final String? externalTxnId;

  final IngestSource ingestSource;
  final String? note;
  final DateTime createdAt;

  String get currency => amount.currency;

  Payment copyWith({
    Money? amount,
    DateTime? receivedAt,
    PaymentMethod? method,
    String? reference,
    bool clearReference = false,
    String? externalTxnId,
    bool clearExternalTxnId = false,
    IngestSource? ingestSource,
    String? note,
    bool clearNote = false,
  }) {
    return Payment(
      id: id,
      milestoneId: milestoneId,
      amount: amount ?? this.amount,
      receivedAt: receivedAt ?? this.receivedAt,
      method: method ?? this.method,
      reference: clearReference ? null : (reference ?? this.reference),
      externalTxnId:
          clearExternalTxnId ? null : (externalTxnId ?? this.externalTxnId),
      ingestSource: ingestSource ?? this.ingestSource,
      note: clearNote ? null : (note ?? this.note),
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) => other is Payment && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
