import '../../domain/entities/payment.dart';
import 'csv_table.dart';

/// Whether an ingested amount is money that arrived or money still owed.
enum PaymentKind {
  /// A payout that has landed — record it as a payment.
  received,

  /// An invoice or promise of future payment — record it as an outstanding
  /// milestone, not a settled one.
  owed,
}

/// The app's read of what an ingested item *is*, so the review queue can
/// pre-select the right action instead of making the user open the mail.
///
/// It is a guess, scored and explained, never a silent decision: the kind and
/// the evidence are shown, the user can flip it, and nothing reaches the ledger
/// without that confirmation. The point is to turn "read the email and decide"
/// into "glance at the app's guess and tap".
class PaymentClassification {
  const PaymentClassification({
    required this.kind,
    required this.confidence,
    required this.reasons,
    this.dueDate,
  });

  final PaymentKind kind;

  /// 0–100. High enough to trust for a one-tap confirm; not a probability.
  final int confidence;

  /// Plain-language evidence, shown so the guess can be judged.
  final List<String> reasons;

  /// The payment due date, when the text states one. Only meaningful for
  /// [PaymentKind.owed].
  final DateTime? dueDate;

  bool get isConfident => confidence >= 70;
}

/// Phrases that mean money has already arrived.
const List<String> _receivedCues = <String>[
  'payment received',
  'you have been paid',
  "you've been paid",
  'has been paid',
  'funds available',
  'funds are available',
  'credited to your',
  'has been credited',
  'deposited',
  'payout',
  'paid to you',
  'payment cleared',
  'has cleared',
  'settled',
  'you earned',
  'you have earned',
  'received with thanks',
];

/// Phrases that mean money is still owed.
const List<String> _owedCues = <String>[
  'invoice',
  'amount due',
  'payment due',
  'due by',
  'due on',
  'outstanding',
  'balance due',
  'please pay',
  'kindly pay',
  'pending payment',
  'awaiting payment',
  'will receive',
  'you will be paid',
  'to be paid',
  'payable',
  'net 15',
  'net 30',
];

/// Classifies [text] as a received payment or an amount owed.
///
/// Statements and notifications are payout artefacts by nature, so they are
/// received with high confidence without reading the words. Email is scored on
/// its wording — plus any due date, which only an invoice carries.
PaymentClassification classifyPayment({
  required String text,
  required IngestSource channel,
  required DateTime occurredAt,
}) {
  if (channel == IngestSource.statement ||
      channel == IngestSource.notification) {
    return const PaymentClassification(
      kind: PaymentKind.received,
      confidence: 95,
      reasons: <String>['A payout statement or notification reports money '
          'that has already arrived'],
    );
  }

  final String lower = text.toLowerCase();
  final List<String> reasons = <String>[];
  int received = 0;
  int owed = 0;

  for (final String cue in _receivedCues) {
    if (lower.contains(cue)) {
      received++;
      reasons.add('Says "$cue"');
    }
  }
  for (final String cue in _owedCues) {
    if (lower.contains(cue)) {
      owed++;
      reasons.add('Says "$cue"');
    }
  }

  final DateTime? dueDate = extractDueDate(text);
  if (dueDate != null) {
    owed++;
    reasons.add('States a due date');
  }

  final PaymentKind kind = owed > received ? PaymentKind.owed
      : received > owed ? PaymentKind.received
      // A tie, or no signal, leans received: a custom sender you added is
      // usually telling you money arrived, and the review queue still asks.
      : PaymentKind.received;

  final int confidence = (50 + (received - owed).abs() * 20).clamp(0, 95);

  return PaymentClassification(
    kind: kind,
    confidence: confidence,
    reasons: reasons.isEmpty
        ? <String>['No clear wording either way — defaulted to received']
        : reasons,
    dueDate: kind == PaymentKind.owed ? dueDate : null,
  );
}

/// Pulls a due date out of phrasing like "due by 15 Dec 2026", "payable by
/// 2026-12-15", "due on Dec 15, 2026". Returns null when none is stated.
DateTime? extractDueDate(String text) {
  final RegExpMatch? match = RegExp(
    r'\b(?:due|payable|pay)\s*(?:by|on|before|on or before)?[:\s]*'
    r'(\d{4}-\d{2}-\d{2}'
    r'|\d{1,2}[\s\-/][A-Za-z]{3,}[\s\-/,]*\d{2,4}'
    r'|[A-Za-z]{3,}\s+\d{1,2},?\s*\d{4})',
    caseSensitive: false,
  ).firstMatch(text);
  if (match == null) return null;
  return parseStatementDate(match.group(1)!.trim());
}
