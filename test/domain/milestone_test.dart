import 'package:flutter_test/flutter_test.dart';
import 'package:paytrail/domain/entities/milestone.dart';
import 'package:paytrail/domain/money.dart';

/// A fixed "today" so these tests describe behaviour rather than the date they
/// happen to run on.
final DateTime kToday = DateTime(2026, 9, 24);

Milestone milestone({
  int grossMinor = 100000, // 1,000.00
  String currency = 'INR',
  DateTime? dueDate,
  int commissionRateBps = 0,
  int tdsRateBps = 0,
  MilestoneStage stage = MilestoneStage.invoiced,
  int paidMinor = 0,
}) {
  return Milestone(
    id: 'm1',
    projectId: 'p1',
    title: 'Phase 1',
    grossAmount: Money(grossMinor, currency),
    dueDate: dueDate ?? DateTime(2026, 9, 1),
    sourceId: 'direct',
    commissionRateBps: commissionRateBps,
    tdsRateBps: tdsRateBps,
    stage: stage,
    amountPaid: Money(paidMinor, currency),
    createdAt: DateTime(2026, 8, 1),
    updatedAt: DateTime(2026, 8, 1),
  );
}

void main() {
  group('net amount', () {
    test('a direct milestone with no deductions nets the gross', () {
      final Milestone m = milestone();
      expect(m.commission, const Money(0, 'INR'));
      expect(m.tds, const Money(0, 'INR'));
      expect(m.netAmount, const Money(100000, 'INR'));
    });

    test('Fiverr takes 20%', () {
      final Milestone m = milestone(commissionRateBps: 2000);
      expect(m.commission, const Money(20000, 'INR'));
      expect(m.netAmount, const Money(80000, 'INR'));
    });

    test('Upwork takes 10%', () {
      final Milestone m = milestone(commissionRateBps: 1000);
      expect(m.netAmount, const Money(90000, 'INR'));
    });

    test('commission and TDS both come off the gross, not off each other', () {
      // 1,000.00 at 10% commission and 10% TDS nets 800.00 — not 810.00,
      // which is what deducting TDS from the post-commission figure would give.
      final Milestone m = milestone(
        commissionRateBps: 1000,
        tdsRateBps: 1000,
      );
      expect(m.commission, const Money(10000, 'INR'));
      expect(m.tds, const Money(10000, 'INR'));
      expect(m.netAmount, const Money(80000, 'INR'));
    });
  });

  group('outstanding', () {
    test('is the net amount when nothing has been received', () {
      expect(milestone(commissionRateBps: 2000).outstanding,
          const Money(80000, 'INR'));
    });

    test('is measured against net, so a full Fiverr payout closes it', () {
      // The client is billed 1,000 but only 800 ever arrives. The milestone
      // must read as paid, not as 200 short.
      final Milestone m =
          milestone(commissionRateBps: 2000, paidMinor: 80000);
      expect(m.isFullyPaid, isTrue);
      expect(m.outstanding, const Money(0, 'INR'));
      expect(m.statusAsOf(kToday), MilestoneStatus.paid);
    });

    test('a part payment leaves the balance and flags partial', () {
      final Milestone m = milestone(paidMinor: 40000);
      expect(m.outstanding, const Money(60000, 'INR'));
      expect(m.isPartiallyPaid, isTrue);
      expect(m.isFullyPaid, isFalse);
    });

    test('an overpayment reads as zero, never negative', () {
      final Milestone m = milestone(paidMinor: 120000);
      expect(m.outstanding, const Money(0, 'INR'));
      expect(m.isFullyPaid, isTrue);
    });

    test('a client rounding a few paise short still settles it', () {
      final Milestone m = milestone(paidMinor: 99999);
      expect(m.isFullyPaid, isFalse);
      expect(m.outstanding, const Money(1, 'INR'));
    });
  });

  group('overdue', () {
    test('not overdue on the due date itself', () {
      final Milestone m = milestone(dueDate: kToday);
      expect(m.isOverdueAsOf(kToday), isFalse);
      expect(m.daysOverdueAsOf(kToday), 0);
      expect(m.statusAsOf(kToday), MilestoneStatus.invoiced);
    });

    test('one day overdue the day after', () {
      final Milestone m = milestone(dueDate: DateTime(2026, 9, 23));
      expect(m.isOverdueAsOf(kToday), isTrue);
      expect(m.daysOverdueAsOf(kToday), 1);
    });

    test('counts whole days regardless of the time of day', () {
      final Milestone m = milestone(dueDate: DateTime(2026, 8, 25));
      expect(m.daysOverdueAsOf(DateTime(2026, 9, 24, 23, 59)), 30);
      expect(m.daysOverdueAsOf(DateTime(2026, 9, 24, 0, 1)), 30);
    });

    test('a paid milestone is never overdue, however late it was', () {
      final Milestone m = milestone(
        dueDate: DateTime(2025, 1, 1),
        paidMinor: 100000,
      );
      expect(m.isOverdueAsOf(kToday), isFalse);
      expect(m.daysOverdueAsOf(kToday), 0);
      expect(m.statusAsOf(kToday), MilestoneStatus.paid);
    });

    test('a cancelled milestone is never overdue', () {
      final Milestone m = milestone(
        dueDate: DateTime(2025, 1, 1),
        stage: MilestoneStage.cancelled,
      );
      expect(m.isOverdueAsOf(kToday), isFalse);
      expect(m.statusAsOf(kToday), MilestoneStatus.cancelled);
      expect(m.isFullyPaid, isFalse);
    });

    test('daysUntilDue goes negative once past due', () {
      expect(
        milestone(dueDate: DateTime(2026, 10, 1)).daysUntilDueAsOf(kToday),
        7,
      );
      expect(
        milestone(dueDate: DateTime(2026, 9, 17)).daysUntilDueAsOf(kToday),
        -7,
      );
    });
  });

  group('status precedence', () {
    test('overdue outranks partially paid', () {
      final Milestone m = milestone(
        dueDate: DateTime(2026, 7, 26),
        paidMinor: 50000,
      );
      expect(m.isPartiallyPaid, isTrue);
      expect(m.statusAsOf(kToday), MilestoneStatus.overdue);
      expect(m.daysOverdueAsOf(kToday), 60);
    });

    test('paid outranks overdue', () {
      final Milestone m = milestone(
        dueDate: DateTime(2025, 1, 1),
        paidMinor: 100000,
      );
      expect(m.statusAsOf(kToday), MilestoneStatus.paid);
    });

    test('cancelled outranks everything', () {
      final Milestone m = milestone(
        dueDate: DateTime(2025, 1, 1),
        paidMinor: 100000,
        stage: MilestoneStage.cancelled,
      );
      expect(m.statusAsOf(kToday), MilestoneStatus.cancelled);
    });

    test('partially paid shows when the milestone is not yet due', () {
      final Milestone m = milestone(
        dueDate: DateTime(2026, 10, 30),
        paidMinor: 50000,
      );
      expect(m.statusAsOf(kToday), MilestoneStatus.partiallyPaid);
    });

    test('an un-invoiced milestone reads as pending', () {
      final Milestone m = milestone(
        dueDate: DateTime(2026, 10, 30),
        stage: MilestoneStage.pending,
      );
      expect(m.statusAsOf(kToday), MilestoneStatus.pending);
    });
  });
}
