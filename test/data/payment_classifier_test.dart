import 'package:flutter_test/flutter_test.dart';
import 'package:paytrail/data/ingest/payment_classifier.dart';
import 'package:paytrail/domain/entities/payment.dart';

void main() {
  PaymentClassification classify(
    String text, {
    IngestSource channel = IngestSource.email,
  }) =>
      classifyPayment(
        text: text,
        channel: channel,
        occurredAt: DateTime(2026, 10, 1),
      );

  group('classifyPayment', () {
    test('a payout statement is received without reading the words', () {
      final PaymentClassification c =
          classify('anything', channel: IngestSource.statement);
      expect(c.kind, PaymentKind.received);
      expect(c.isConfident, isTrue);
    });

    test('"you received X for Z" reads as received', () {
      final PaymentClassification c =
          classify('You have been paid \$500 for the logo work.');
      expect(c.kind, PaymentKind.received);
    });

    test('"you will receive X by Y" reads as owed, with the due date', () {
      final PaymentClassification c =
          classify('You will receive ₹50,000 for the website, due by 2026-12-01.');
      expect(c.kind, PaymentKind.owed);
      expect(c.dueDate, DateTime(2026, 12, 1));
    });

    test('an invoice with an amount due reads as owed', () {
      final PaymentClassification c = classify(
        'Invoice #1002. Amount due ₹25,000. Please pay by 15 Dec 2026.',
      );
      expect(c.kind, PaymentKind.owed);
      expect(c.dueDate, DateTime(2026, 12, 15));
    });

    test('reasons are populated so the guess can be judged', () {
      final PaymentClassification c = classify('Payment received, thank you.');
      expect(c.reasons, isNotEmpty);
    });

    test('ambiguous text defaults to received rather than guessing owed', () {
      final PaymentClassification c = classify('Here is an update on the job.');
      expect(c.kind, PaymentKind.received);
      expect(c.isConfident, isFalse);
    });

    test('no due date reported when none is stated', () {
      expect(extractDueDate('Thanks for the work, cheers'), isNull);
    });
  });
}
