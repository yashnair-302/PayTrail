import 'package:flutter_test/flutter_test.dart';
import 'package:paytrail/data/ingest/csv_table.dart';
import 'package:paytrail/data/ingest/fiverr_source.dart';
import 'package:paytrail/data/ingest/upwork_source.dart';
import 'package:paytrail/domain/entities/payment.dart';
import 'package:paytrail/domain/ingest/payment_event.dart';
import 'package:paytrail/domain/ingest/payment_source_adapter.dart';
import 'package:paytrail/domain/money.dart';

void main() {
  group('parseStatementDate', () {
    test('reads ISO, textual and numeric forms', () {
      expect(parseStatementDate('2026-03-12'), DateTime(2026, 3, 12));
      expect(parseStatementDate('12 Mar 2026'), DateTime(2026, 3, 12));
      expect(parseStatementDate('Mar 12, 2026'), DateTime(2026, 3, 12));
      expect(parseStatementDate('12-Mar-2026'), DateTime(2026, 3, 12));
    });

    test('reads an ambiguous numeric date day-first', () {
      // 03/04/2026 is 3 April, not 4 March — the Indian convention, fixed here
      // rather than left to the device locale.
      expect(parseStatementDate('03/04/2026'), DateTime(2026, 4, 3));
    });

    test('returns null rather than guessing at nonsense', () {
      expect(parseStatementDate(''), isNull);
      expect(parseStatementDate('not a date'), isNull);
      expect(parseStatementDate('45/45/2026'), isNull);
    });
  });

  group('splitAmountCell', () {
    test('strips symbols, codes and separators', () {
      expect(splitAmountCell(r'$1,200.00')?.digits, '1200.00');
      expect(splitAmountCell(r'$1,200.00')?.currency, 'USD');
      expect(splitAmountCell('1,200.00 USD')?.currency, 'USD');
      expect(splitAmountCell('₹4,500')?.currency, 'INR');
    });

    test('reads accounting negatives', () {
      expect(splitAmountCell(r'($40.00)')?.digits, '-40.00');
      expect(splitAmountCell('-40.00')?.digits, '-40.00');
    });

    test('rejects a cell that is not an amount', () {
      expect(splitAmountCell(''), isNull);
      expect(splitAmountCell('n/a'), isNull);
      expect(splitAmountCell('--'), isNull);
    });
  });

  group('firstAmountIn', () {
    test('finds an amount in a sentence', () {
      expect(firstAmountIn(r'You earned $120.00 from Order FO123456'),
          const Money(12000, 'USD'));
      expect(firstAmountIn('Payment of ₹4,500 has cleared'),
          const Money(450000, 'INR'));
      expect(firstAmountIn('You received 250 USD'), const Money(25000, 'USD'));
    });

    test('returns null when there is no money in the text', () {
      expect(firstAmountIn('Your order was delivered'), isNull);
    });
  });

  group('FiverrSource.parseStatement', () {
    const FiverrSource fiverr = FiverrSource();

    test('reads earnings rows with gross, fee and net', () {
      const String csv = '''
Date,Order ID,Type,Amount,Service fee,Net amount,Buyer,Description
2026-03-12,FO12345678,Earning,\$200.00,\$40.00,\$160.00,acme_studio,Logo design
2026-03-20,FO12345679,Earning,\$100.00,\$20.00,\$80.00,globex,Banner set
''';
      final IngestResult result = fiverr.parseStatement(csv);

      expect(result.events, hasLength(2));
      expect(result.issues, isEmpty);

      final PaymentEvent first = result.events.first;
      expect(first.sourceId, 'fiverr');
      expect(first.channel, IngestSource.statement);
      expect(first.grossAmount, const Money(20000, 'USD'));
      expect(first.netAmount, const Money(16000, 'USD'));
      expect(first.externalTxnId, 'FO12345678');
      expect(first.clientHint, 'acme_studio');
      expect(first.occurredAt, DateTime(2026, 3, 12));
      // The net figure is what the importer will record.
      expect(first.amountToRecord, const Money(16000, 'USD'));
    });

    test('derives net from the fee when no net column is present', () {
      const String csv = '''
Date,Order ID,Type,Amount,Service fee
2026-03-12,FO1,Earning,\$200.00,\$40.00
''';
      final PaymentEvent event = fiverr.parseStatement(csv).events.single;
      expect(event.netAmount, const Money(16000, 'USD'));
    });

    test('leaves net unknown when the export states neither', () {
      const String csv = '''
Date,Order ID,Type,Amount
2026-03-12,FO1,Earning,\$200.00
''';
      final PaymentEvent event = fiverr.parseStatement(csv).events.single;
      expect(event.netAmount, isNull);
      // Falls back to gross rather than inventing a deduction here; the
      // milestone's own rate settles it at import time.
      expect(event.amountToRecord, const Money(20000, 'USD'));
    });

    test('skips withdrawals and adjustments', () {
      const String csv = '''
Date,Order ID,Type,Amount
2026-03-12,FO1,Earning,\$200.00
2026-03-13,,Withdrawal,\$150.00
2026-03-14,,Balance adjustment,\$5.00
''';
      final IngestResult result = fiverr.parseStatement(csv);
      expect(result.events, hasLength(1));
      expect(result.events.single.externalTxnId, 'FO1');
    });

    test('a bad row is reported, not fatal to the rest of the file', () {
      const String csv = '''
Date,Order ID,Type,Amount
2026-03-12,FO1,Earning,\$200.00
oops,FO2,Earning,\$100.00
2026-03-14,FO3,Earning,\$50.00
''';
      final IngestResult result = fiverr.parseStatement(csv);
      expect(result.events, hasLength(2));
      expect(result.issues, hasLength(1));
      expect(result.issues.single.lineNumber, 3);
    });

    test('tolerates renamed and reordered columns', () {
      const String csv = '''
"Buyer","Amount (USD)","Created at","Type","Order number"
"acme","\$200.00","12 Mar 2026","Order completed","FO9"
''';
      final PaymentEvent event = fiverr.parseStatement(csv).events.single;
      expect(event.grossAmount, const Money(20000, 'USD'));
      expect(event.externalTxnId, 'FO9');
      expect(event.occurredAt, DateTime(2026, 3, 12));
    });

    test('reads a real Fiverr export: Username, Gig, Order Total, Currency', () {
      // The column names Fiverr's own earnings export actually uses.
      const String csv = '''
Order Number,Date,Username,Gig,Order Total,Service Fee,Earnings,Activity,Currency
FO55501,2026-10-05,acme_studio,Logo design package,500.00,100.00,400.00,Order completed,USD
FO55502,2026-10-12,bluewave_co,Landing page copy,250.00,50.00,200.00,Earning,USD
''';
      final IngestResult result = fiverr.parseStatement(csv);

      expect(result.events, hasLength(2));
      final PaymentEvent first = result.events.first;
      // Order Total → gross, Earnings → net, both in the stated currency.
      expect(first.grossAmount, const Money(50000, 'USD'));
      expect(first.netAmount, const Money(40000, 'USD'));
      expect(first.externalTxnId, 'FO55501');
      expect(first.clientHint, 'acme_studio'); // Username
      expect(first.description, 'Logo design package'); // Gig
    });

    test('honours a non-USD Currency column on bare amounts', () {
      const String csv = '''
Order Number,Date,Username,Order Total,Earnings,Activity,Currency
FO700,2026-10-05,desi_client,4500,4500,Earning,INR
''';
      final PaymentEvent event = fiverr.parseStatement(csv).events.single;
      expect(event.grossAmount, const Money(450000, 'INR'));
    });

    test('rejects a file that is not a Fiverr export', () {
      const String csv = 'Name,Email\nSomebody,a@b.com\n';
      final IngestResult result = fiverr.parseStatement(csv);
      expect(result.events, isEmpty);
      expect(result.issues.single.detail, contains('does not look like'));
    });

    test('rejects an empty file', () {
      expect(fiverr.parseStatement('').events, isEmpty);
      expect(fiverr.parseStatement('').issues, isNotEmpty);
    });
  });

  group('UpworkSource.parseStatement', () {
    const UpworkSource upwork = UpworkSource();

    test('reads earnings and uses the currency column', () {
      const String csv = '''
Date,Ref ID,Type,Description,Amount,Currency,Team
2026-03-12,REF1001,Fixed Price,Milestone 1,500.00,USD,Acme Studio
2026-03-15,REF1002,Hourly,Week 11,320.50,USD,Globex
''';
      final IngestResult result = upwork.parseStatement(csv);

      expect(result.events, hasLength(2));
      final PaymentEvent first = result.events.first;
      expect(first.sourceId, 'upwork');
      expect(first.grossAmount, const Money(50000, 'USD'));
      // Upwork reports amounts already net of its fee.
      expect(first.netAmount, const Money(50000, 'USD'));
      expect(first.externalTxnId, 'REF1001');
      expect(first.clientHint, 'Acme Studio');
    });

    test('excludes service fees, withdrawals and refunds', () {
      const String csv = '''
Date,Ref ID,Type,Amount,Currency
2026-03-12,R1,Fixed Price,500.00,USD
2026-03-12,R2,Service Fee,-50.00,USD
2026-03-13,R3,Withdrawal,-400.00,USD
2026-03-14,R4,Refund,-100.00,USD
''';
      final IngestResult result = upwork.parseStatement(csv);
      expect(result.events, hasLength(1));
      expect(result.events.single.externalTxnId, 'R1');
    });

    test('skips negative amounts even on an earnings row type', () {
      const String csv = '''
Date,Ref ID,Type,Amount,Currency
2026-03-12,R1,Fixed Price,-500.00,USD
''';
      expect(upwork.parseStatement(csv).events, isEmpty);
    });

    test('rejects a Fiverr export handed to the Upwork parser', () {
      const String csv = 'Buyer,Gig,Rating\nacme,Logo,5\n';
      final IngestResult result = upwork.parseStatement(csv);
      expect(result.events, isEmpty);
      expect(result.issues.single.detail, contains('Upwork'));
    });
  });

  group('email parsing', () {
    const FiverrSource fiverr = FiverrSource();
    const UpworkSource upwork = UpworkSource();

    EmailMessage message({
      required String from,
      required String subject,
      String body = '',
    }) =>
        EmailMessage(
          id: 'm1',
          fromAddress: from,
          subject: subject,
          body: body,
          receivedAt: DateTime(2026, 3, 12, 14, 30),
        );

    test('reads a Fiverr order-completed notice', () {
      final PaymentEvent? event = fiverr.parseEmail(
        message(
          from: 'no-reply@fiverr.com',
          subject: 'Your order FO12345678 is completed',
          body: r'You earned $160.00. Funds will clear in 14 days.',
        ),
      );

      expect(event, isNotNull);
      expect(event!.grossAmount, const Money(16000, 'USD'));
      expect(event.externalTxnId, 'FO12345678');
      expect(event.channel, IngestSource.email);
      // Reduced to the calendar day so the dedupe key lines up with the
      // statement row for the same payment.
      expect(event.occurredAt, DateTime(2026, 3, 12));
    });

    test('ignores mail from outside the allowlisted domains', () {
      // The critical privacy test: even a message that looks exactly like a
      // payment notice is not read if it did not come from the platform.
      final PaymentEvent? event = fiverr.parseEmail(
        message(
          from: 'attacker@example.com',
          subject: 'Your order FO12345678 is completed',
          body: r'You earned $160.00',
        ),
      );
      expect(event, isNull);
    });

    test('ignores platform mail that is not about money', () {
      expect(
        fiverr.parseEmail(
          message(
            from: 'no-reply@fiverr.com',
            subject: 'Tips to improve your gig ranking',
            body: r'Sellers who respond in 1 hour earn $500 more on average',
          ),
        ),
        isNull,
      );
    });

    test('ignores a payment-shaped subject with no amount in it', () {
      expect(
        fiverr.parseEmail(
          message(
            from: 'no-reply@fiverr.com',
            subject: 'Your order FO1 is completed',
            body: 'Leave a review for your buyer.',
          ),
        ),
        isNull,
      );
    });

    test('reads an Upwork payment notice', () {
      final PaymentEvent? event = upwork.parseEmail(
        message(
          from: 'do-not-reply@mail.upwork.com',
          subject: 'Your payment has been processed',
          body: r'$450.00 for contract 987654321. Ref ID: REF20263012',
        ),
      );

      expect(event, isNotNull);
      expect(event!.grossAmount, const Money(45000, 'USD'));
      expect(event.projectHint, '987654321');
      expect(event.externalTxnId, 'REF20263012');
    });

    test('each adapter ignores the other platform', () {
      final EmailMessage upworkMail = message(
        from: 'do-not-reply@mail.upwork.com',
        subject: 'Your payment has been processed',
        body: r'$450.00',
      );
      expect(fiverr.parseEmail(upworkMail), isNull);
      expect(upwork.parseEmail(upworkMail), isNotNull);
    });
  });

  group('notification parsing', () {
    const FiverrSource fiverr = FiverrSource();
    const UpworkSource upwork = UpworkSource();

    NotificationData notification({
      required String package,
      required String title,
      String text = '',
    }) =>
        NotificationData(
          packageName: package,
          title: title,
          text: text,
          postedAt: DateTime(2026, 3, 12, 9, 5),
        );

    test('reads a Fiverr payout notification', () {
      final PaymentEvent? event = fiverr.parseNotification(
        notification(
          package: 'com.fiverr.fiverr',
          title: 'Funds available',
          text: r'$160.00 from your completed order is now available.',
        ),
      );

      expect(event, isNotNull);
      expect(event!.grossAmount, const Money(16000, 'USD'));
      expect(event.channel, IngestSource.notification);
      // No transaction id is available from a notification — which is exactly
      // why the dedupe key also uses amount and date.
      expect(event.externalTxnId, isNull);
    });

    test('ignores notifications from any other app', () {
      expect(
        fiverr.parseNotification(
          notification(
            package: 'com.whatsapp',
            title: 'Funds available',
            text: r'$160.00',
          ),
        ),
        isNull,
      );
      expect(
        upwork.parseNotification(
          notification(
            package: 'com.bank.app',
            title: 'Payment received',
            text: r'$450.00 credited',
          ),
        ),
        isNull,
      );
    });

    test('ignores platform notifications that are not payments', () {
      expect(
        fiverr.parseNotification(
          notification(
            package: 'com.fiverr.fiverr',
            title: 'You have a new message',
            text: 'acme_studio sent you a message',
          ),
        ),
        isNull,
      );
    });
  });

  group('PaymentSourceRegistry', () {
    const PaymentSourceRegistry registry = PaymentSourceRegistry(
      <PaymentSourceAdapter>[FiverrSource(), UpworkSource()],
    );

    test('resolves an adapter by source id, domain and package', () {
      expect(registry.bySourceId('fiverr'), isA<FiverrSource>());
      expect(registry.byEmailDomain('mail.upwork.com'), isA<UpworkSource>());
      expect(
        registry.byNotificationPackage('com.fiverr.fiverr'),
        isA<FiverrSource>(),
      );
    });

    test('claims nothing it does not own', () {
      expect(registry.byEmailDomain('gmail.com'), isNull);
      expect(registry.byNotificationPackage('com.whatsapp'), isNull);
      expect(registry.bySourceId('toptal'), isNull);
    });

    test('the email allowlist is the union of the adapters', () {
      expect(registry.allEmailDomains, contains('fiverr.com'));
      expect(registry.allEmailDomains, contains('upwork.com'));
      expect(registry.allEmailDomains, isNot(contains('gmail.com')));
    });
  });
}
