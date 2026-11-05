import 'package:flutter_test/flutter_test.dart';
import 'package:paytrail/domain/money.dart';

void main() {
  group('Money.tryParse', () {
    test('reads plain and grouped amounts', () {
      expect(Money.tryParse('1250.50', 'INR'), const Money(125050, 'INR'));
      expect(Money.tryParse('1,250.50', 'INR'), const Money(125050, 'INR'));
      expect(Money.tryParse('1250', 'INR'), const Money(125000, 'INR'));
      expect(Money.tryParse('.5', 'INR'), const Money(50, 'INR'));
      expect(Money.tryParse('-40.25', 'USD'), const Money(-4025, 'USD'));
    });

    test('pads a short fraction instead of misreading it', () {
      // "10.5" is ten rupees fifty paise, not ten rupees five paise.
      expect(Money.tryParse('10.5', 'INR'), const Money(1050, 'INR'));
    });

    test('rounds away precision the currency does not have', () {
      expect(Money.tryParse('10.005', 'INR'), const Money(1001, 'INR'));
      expect(Money.tryParse('10.004', 'INR'), const Money(1000, 'INR'));
    });

    test('honours currencies without minor units', () {
      expect(Money.tryParse('1250', 'JPY'), const Money(1250, 'JPY'));
    });

    test('rejects input that is not an amount', () {
      expect(Money.tryParse('', 'INR'), isNull);
      expect(Money.tryParse('abc', 'INR'), isNull);
      expect(Money.tryParse('12.3.4', 'INR'), isNull);
      expect(Money.tryParse('-', 'INR'), isNull);
      expect(Money.tryParse('1' * 20, 'INR'), isNull);
    });
  });

  group('arithmetic', () {
    test('adds and subtracts exactly', () {
      // The case a double gets wrong: 0.1 + 0.2 must be exactly 0.3.
      final Money a = Money.tryParse('0.10', 'INR')!;
      final Money b = Money.tryParse('0.20', 'INR')!;
      expect(a + b, Money.tryParse('0.30', 'INR'));
      expect((a + b).toDecimalString(), '0.30');
    });

    test('refuses to mix currencies', () {
      expect(
        () => const Money(100, 'INR') + const Money(100, 'USD'),
        throwsArgumentError,
      );
    });

    test('clampToZero hides an overpayment rather than showing a negative', () {
      expect(const Money(-500, 'INR').clampToZero(), const Money(0, 'INR'));
      expect(const Money(500, 'INR').clampToZero(), const Money(500, 'INR'));
    });
  });

  group('percentage', () {
    test('applies a commission rate in basis points', () {
      // Fiverr: 20% of 10,000.00 is 2,000.00.
      expect(
        Money.tryParse('10000', 'INR')!.percentage(2000),
        Money.tryParse('2000', 'INR'),
      );
      // Upwork: 10% of 1,234.56.
      expect(
        Money.tryParse('1234.56', 'INR')!.percentage(1000),
        Money.tryParse('123.46', 'INR'),
      );
    });

    test('rounds half away from zero', () {
      // 5% of 0.10 is 0.005, which must round up to one paisa.
      expect(Money.tryParse('0.10', 'INR')!.percentage(500),
          const Money(1, 'INR'));
      expect(const Money(-10, 'INR').percentage(500), const Money(-1, 'INR'));
    });

    test('a zero rate deducts nothing', () {
      expect(const Money(99999, 'INR').percentage(0), const Money(0, 'INR'));
    });
  });

  group('toDecimalString', () {
    test('keeps trailing zeros and the sign', () {
      expect(const Money(125000, 'INR').toDecimalString(), '1250.00');
      expect(const Money(5, 'INR').toDecimalString(), '0.05');
      expect(const Money(-5, 'INR').toDecimalString(), '-0.05');
      expect(const Money(1250, 'JPY').toDecimalString(), '1250');
    });
  });

  group('sumMoney', () {
    test('totals a list in one currency', () {
      expect(
        sumMoney(
          <Money>[
            const Money(100, 'INR'),
            const Money(250, 'INR'),
            const Money(-50, 'INR'),
          ],
          'INR',
        ),
        const Money(300, 'INR'),
      );
    });

    test('an empty list is zero, not null', () {
      expect(sumMoney(const <Money>[], 'INR'), const Money(0, 'INR'));
    });

    test('refuses a foreign currency in the list', () {
      expect(
        () => sumMoney(<Money>[const Money(100, 'USD')], 'INR'),
        throwsArgumentError,
      );
    });
  });
}
