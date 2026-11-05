import 'package:flutter_test/flutter_test.dart';
import 'package:paytrail/domain/aging.dart';
import 'package:paytrail/domain/entities/client.dart';
import 'package:paytrail/domain/entities/milestone.dart';
import 'package:paytrail/domain/entities/payment_source.dart';
import 'package:paytrail/domain/entities/project.dart';
import 'package:paytrail/domain/money.dart';
import 'package:paytrail/domain/repositories/ledger_repository.dart';

final DateTime kToday = DateTime(2026, 9, 25);

Client _client(String id, String name) => Client(
      id: id,
      name: name,
      createdAt: kToday,
      updatedAt: kToday,
    );

Project _project(String id, String clientId) => Project(
      id: id,
      clientId: clientId,
      name: 'Project $id',
      defaultSourceId: SourceIds.direct,
      defaultCurrency: 'INR',
      createdAt: kToday,
      updatedAt: kToday,
    );

/// A milestone due [daysAgo] days ago (negative for future), with [grossMinor]
/// billed and [paidMinor] received.
MilestoneWithContext _item({
  required String id,
  required int daysAgo,
  int grossMinor = 100000,
  int paidMinor = 0,
  String currency = 'INR',
  String sourceId = SourceIds.direct,
  String clientId = 'c1',
  MilestoneStage stage = MilestoneStage.invoiced,
  int commissionRateBps = 0,
}) {
  return MilestoneWithContext(
    milestone: Milestone(
      id: id,
      projectId: 'p1',
      title: 'Milestone $id',
      grossAmount: Money(grossMinor, currency),
      dueDate: kToday.subtract(Duration(days: daysAgo)),
      sourceId: sourceId,
      commissionRateBps: commissionRateBps,
      tdsRateBps: 0,
      stage: stage,
      amountPaid: Money(paidMinor, currency),
      createdAt: kToday,
      updatedAt: kToday,
    ),
    project: _project('p1', clientId),
    client: _client(clientId, 'Client $clientId'),
  );
}

const List<PaymentSource> _sources = kBuiltInSources;

DashboardSummary _build(List<MilestoneWithContext> open) => buildDashboard(
      open: open,
      sources: _sources,
      asOf: kToday,
    );

void main() {
  group('AgingBucket.forDaysOverdue', () {
    test('maps each boundary to the right band', () {
      expect(AgingBucket.forDaysOverdue(-5), AgingBucket.notYetDue);
      expect(AgingBucket.forDaysOverdue(0), AgingBucket.notYetDue);
      expect(AgingBucket.forDaysOverdue(1), AgingBucket.days0to30);
      expect(AgingBucket.forDaysOverdue(30), AgingBucket.days0to30);
      expect(AgingBucket.forDaysOverdue(31), AgingBucket.days31to60);
      expect(AgingBucket.forDaysOverdue(60), AgingBucket.days31to60);
      expect(AgingBucket.forDaysOverdue(61), AgingBucket.days61to90);
      expect(AgingBucket.forDaysOverdue(90), AgingBucket.days61to90);
      expect(AgingBucket.forDaysOverdue(91), AgingBucket.days90plus);
      expect(AgingBucket.forDaysOverdue(3650), AgingBucket.days90plus);
    });

    test('only the overdue bands are marked overdue', () {
      expect(AgingBucket.notYetDue.isOverdue, isFalse);
      for (final AgingBucket bucket in AgingBucket.values.skip(1)) {
        expect(bucket.isOverdue, isTrue, reason: bucket.name);
      }
    });
  });

  group('empty ledger', () {
    test('produces an empty summary, not a crash', () {
      final DashboardSummary summary = _build(<MilestoneWithContext>[]);
      expect(summary.hasAnythingOutstanding, isFalse);
      expect(summary.totalOutstanding.isEmpty, isTrue);
      expect(summary.aging, isEmpty);
      expect(summary.bySource, isEmpty);
    });
  });

  group('totals', () {
    test('outstanding covers every live milestone, overdue only the late ones',
        () {
      final DashboardSummary summary = _build(<MilestoneWithContext>[
        _item(id: 'a', daysAgo: -10), // future
        _item(id: 'b', daysAgo: 5), // late
        _item(id: 'c', daysAgo: 100), // very late
      ]);

      expect(
        summary.totalOutstanding.inCurrency('INR'),
        const Money(300000, 'INR'),
      );
      expect(summary.totalOverdue.inCurrency('INR'), const Money(200000, 'INR'));
      expect(summary.openMilestoneCount, 3);
      expect(summary.overdueMilestoneCount, 2);
    });

    test('measures against net, so commission is already deducted', () {
      final DashboardSummary summary = _build(<MilestoneWithContext>[
        _item(
          id: 'a',
          daysAgo: 5,
          sourceId: SourceIds.fiverr,
          commissionRateBps: 2000,
        ),
      ]);
      expect(
        summary.totalOutstanding.inCurrency('INR'),
        const Money(80000, 'INR'),
      );
    });

    test('a part payment reduces the outstanding total, not the count', () {
      final DashboardSummary summary = _build(<MilestoneWithContext>[
        _item(id: 'a', daysAgo: 5, paidMinor: 40000),
      ]);
      expect(
        summary.totalOutstanding.inCurrency('INR'),
        const Money(60000, 'INR'),
      );
      expect(summary.openMilestoneCount, 1);
    });

    test('settled and cancelled work is excluded even if passed in', () {
      final DashboardSummary summary = _build(<MilestoneWithContext>[
        _item(id: 'a', daysAgo: 5),
        _item(id: 'b', daysAgo: 5, paidMinor: 100000), // settled
        _item(id: 'c', daysAgo: 5, stage: MilestoneStage.cancelled),
      ]);
      expect(summary.openMilestoneCount, 1);
      expect(
        summary.totalOutstanding.inCurrency('INR'),
        const Money(100000, 'INR'),
      );
    });

    test('counts distinct clients, not milestones', () {
      final DashboardSummary summary = _build(<MilestoneWithContext>[
        _item(id: 'a', daysAgo: 5, clientId: 'c1'),
        _item(id: 'b', daysAgo: 5, clientId: 'c1'),
        _item(id: 'c', daysAgo: -5, clientId: 'c2'),
      ]);
      expect(summary.clientCount, 2);
      expect(summary.overdueClientCount, 1);
    });
  });

  group('aging bands', () {
    test('all five bands are always present, in order', () {
      final DashboardSummary summary =
          _build(<MilestoneWithContext>[_item(id: 'a', daysAgo: 5)]);
      expect(
        summary.aging.map((AgingBand b) => b.bucket),
        AgingBucket.values,
      );
    });

    test('each milestone lands in exactly one band', () {
      final DashboardSummary summary = _build(<MilestoneWithContext>[
        _item(id: 'a', daysAgo: -3), // not yet due
        _item(id: 'b', daysAgo: 15), // 0–30
        _item(id: 'c', daysAgo: 45), // 31–60
        _item(id: 'd', daysAgo: 75), // 61–90
        _item(id: 'e', daysAgo: 200), // 90+
      ]);

      for (final AgingBand band in summary.aging) {
        expect(band.milestoneCount, 1, reason: band.bucket.name);
        expect(
          band.amount.inCurrency('INR'),
          const Money(100000, 'INR'),
          reason: band.bucket.name,
        );
      }
    });

    test('the bands reconcile with the headline total', () {
      final List<MilestoneWithContext> items = <MilestoneWithContext>[
        _item(id: 'a', daysAgo: -3),
        _item(id: 'b', daysAgo: 15, grossMinor: 50000),
        _item(id: 'c', daysAgo: 95, grossMinor: 25000),
      ];
      final DashboardSummary summary = _build(items);

      final int bandTotal = summary.aging.fold<int>(
        0,
        (int sum, AgingBand band) =>
            sum + band.amount.inCurrency('INR').minorUnits,
      );
      expect(bandTotal, summary.totalOutstanding.inCurrency('INR').minorUnits);
    });

    test('an empty band is present with a zero amount', () {
      final DashboardSummary summary =
          _build(<MilestoneWithContext>[_item(id: 'a', daysAgo: 200)]);
      final AgingBand empty = summary.band(AgingBucket.days0to30);
      expect(empty.milestoneCount, 0);
      expect(empty.isEmpty, isTrue);
      expect(empty.amount.isEmpty, isTrue);
    });
  });

  group('source breakdown', () {
    test('groups by the milestone source and names it', () {
      final DashboardSummary summary = _build(<MilestoneWithContext>[
        _item(id: 'a', daysAgo: 5, sourceId: SourceIds.fiverr),
        _item(id: 'b', daysAgo: 5, sourceId: SourceIds.fiverr),
        _item(id: 'c', daysAgo: -5, sourceId: SourceIds.direct),
      ]);

      expect(summary.bySource, hasLength(2));
      final SourceBreakdown fiverr = summary.bySource
          .firstWhere((SourceBreakdown b) => b.sourceId == SourceIds.fiverr);
      expect(fiverr.displayName, 'Fiverr');
      expect(fiverr.milestoneCount, 2);
      expect(fiverr.overdueCount, 2);

      final SourceBreakdown direct = summary.bySource
          .firstWhere((SourceBreakdown b) => b.sourceId == SourceIds.direct);
      expect(direct.overdueCount, 0);
      expect(direct.overdue.isEmpty, isTrue);
    });

    test('sources with nothing outstanding do not appear', () {
      final DashboardSummary summary = _build(<MilestoneWithContext>[
        _item(id: 'a', daysAgo: 5, sourceId: SourceIds.upwork),
      ]);
      expect(summary.bySource, hasLength(1));
      expect(summary.bySource.single.sourceId, SourceIds.upwork);
    });

    test('an unknown source id falls back to the id rather than crashing', () {
      final DashboardSummary summary = _build(<MilestoneWithContext>[
        _item(id: 'a', daysAgo: 5, sourceId: 'toptal'),
      ]);
      expect(summary.bySource.single.displayName, 'toptal');
    });
  });

  group('multi-currency', () {
    test('keeps currencies separate throughout', () {
      final DashboardSummary summary = _build(<MilestoneWithContext>[
        _item(id: 'a', daysAgo: 5),
        _item(id: 'b', daysAgo: 5, currency: 'USD', grossMinor: 40000),
      ]);

      expect(summary.totalOutstanding.currencies, <String>['INR', 'USD']);
      expect(
        summary.totalOutstanding.inCurrency('USD'),
        const Money(40000, 'USD'),
      );
      expect(
        summary.band(AgingBucket.days0to30).amount.currencies,
        <String>['INR', 'USD'],
      );
    });
  });

  group('the chase list', () {
    test('is overdue only, oldest first', () {
      final DashboardSummary summary = _build(<MilestoneWithContext>[
        _item(id: 'recent', daysAgo: 2),
        _item(id: 'ancient', daysAgo: 200),
        _item(id: 'future', daysAgo: -10),
        _item(id: 'middling', daysAgo: 40),
      ]);

      expect(
        summary.overdueMilestones.map((MilestoneWithContext m) => m.milestone.id),
        <String>['ancient', 'middling', 'recent'],
      );
    });
  });
}
