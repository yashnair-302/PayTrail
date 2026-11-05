import 'entities/payment_source.dart';
import 'money_bag.dart';
import 'repositories/ledger_repository.dart';

/// Aging analysis and the dashboard roll-up.
///
/// Pure functions over a list of open milestones: given the same input and the
/// same `asOf` date they always produce the same report, so the whole of this
/// file is testable without a database or a widget tree. The dashboard screen
/// does no arithmetic of its own.

/// How long a debt has been overdue.
///
/// The four overdue bands are the standard receivables buckets and match what a
/// chartered accountant expects to see. [notYetDue] is not an aging bucket in
/// the accounting sense, but the app needs somewhere to put work that is
/// outstanding and perfectly healthy — without it the "total outstanding"
/// figure would not reconcile with the buckets beneath it.
enum AgingBucket {
  notYetDue,
  days0to30,
  days31to60,
  days61to90,
  days90plus;

  String get label => switch (this) {
        AgingBucket.notYetDue => 'Not yet due',
        AgingBucket.days0to30 => '0–30 days',
        AgingBucket.days31to60 => '31–60 days',
        AgingBucket.days61to90 => '61–90 days',
        AgingBucket.days90plus => '90+ days',
      };

  /// True for the bands that represent money that is actually late.
  bool get isOverdue => this != AgingBucket.notYetDue;

  /// Which band [daysOverdue] falls into. Zero or less means not yet due.
  static AgingBucket forDaysOverdue(int daysOverdue) {
    if (daysOverdue <= 0) return AgingBucket.notYetDue;
    if (daysOverdue <= 30) return AgingBucket.days0to30;
    if (daysOverdue <= 60) return AgingBucket.days31to60;
    if (daysOverdue <= 90) return AgingBucket.days61to90;
    return AgingBucket.days90plus;
  }
}

/// One row of the aging table.
class AgingBand {
  const AgingBand({
    required this.bucket,
    required this.amount,
    required this.milestoneCount,
  });

  final AgingBucket bucket;
  final MoneyBag amount;
  final int milestoneCount;

  bool get isEmpty => milestoneCount == 0;
}

/// Outstanding money attributed to one payment channel.
class SourceBreakdown {
  const SourceBreakdown({
    required this.sourceId,
    required this.displayName,
    required this.outstanding,
    required this.overdue,
    required this.milestoneCount,
    required this.overdueCount,
  });

  final String sourceId;
  final String displayName;
  final MoneyBag outstanding;
  final MoneyBag overdue;
  final int milestoneCount;
  final int overdueCount;
}

/// Everything the dashboard shows, computed in one pass.
class DashboardSummary {
  const DashboardSummary({
    required this.asOf,
    required this.totalOutstanding,
    required this.totalOverdue,
    required this.openMilestoneCount,
    required this.overdueMilestoneCount,
    required this.clientCount,
    required this.overdueClientCount,
    required this.bySource,
    required this.aging,
    required this.overdueMilestones,
  });

  factory DashboardSummary.empty(DateTime asOf) => DashboardSummary(
        asOf: asOf,
        totalOutstanding: MoneyBag.empty(),
        totalOverdue: MoneyBag.empty(),
        openMilestoneCount: 0,
        overdueMilestoneCount: 0,
        clientCount: 0,
        overdueClientCount: 0,
        bySource: const <SourceBreakdown>[],
        aging: const <AgingBand>[],
        overdueMilestones: const <MilestoneWithContext>[],
      );

  final DateTime asOf;

  /// Every unsettled milestone, due or not.
  final MoneyBag totalOutstanding;

  /// The part of [totalOutstanding] that is past its due date.
  final MoneyBag totalOverdue;

  final int openMilestoneCount;
  final int overdueMilestoneCount;

  /// Distinct clients with something outstanding.
  final int clientCount;
  final int overdueClientCount;

  /// One entry per channel that has outstanding money, biggest debt first.
  final List<SourceBreakdown> bySource;

  /// All five bands, always in order and always present — an empty band still
  /// appears so the table does not reflow as debts age.
  final List<AgingBand> aging;

  /// Overdue work, oldest first. This is the chase list.
  final List<MilestoneWithContext> overdueMilestones;

  bool get hasAnythingOutstanding => openMilestoneCount > 0;

  AgingBand band(AgingBucket bucket) =>
      aging.firstWhere((AgingBand b) => b.bucket == bucket);
}

/// Builds the dashboard from the open milestones and the configured sources.
///
/// [open] is expected to be the unsettled set — cancelled and fully paid
/// milestones are filtered out again here anyway, because a caller passing the
/// wrong list should produce a wrong-looking dashboard rather than a total that
/// quietly includes money already banked.
DashboardSummary buildDashboard({
  required List<MilestoneWithContext> open,
  required List<PaymentSource> sources,
  required DateTime asOf,
}) {
  final List<MilestoneWithContext> live = open
      .where((MilestoneWithContext m) =>
          !m.milestone.isCancelled && !m.milestone.isFullyPaid)
      .toList();

  if (live.isEmpty) return DashboardSummary.empty(asOf);

  final Map<String, String> sourceNames = <String, String>{
    for (final PaymentSource source in sources) source.id: source.displayName,
  };

  final List<MilestoneWithContext> overdue = live
      .where((MilestoneWithContext m) => m.milestone.isOverdueAsOf(asOf))
      .toList()
    ..sort((MilestoneWithContext a, MilestoneWithContext b) {
      final int byAge = b.milestone
          .daysOverdueAsOf(asOf)
          .compareTo(a.milestone.daysOverdueAsOf(asOf));
      if (byAge != 0) return byAge;
      return a.client.name.toLowerCase().compareTo(b.client.name.toLowerCase());
    });

  // --- Aging bands ---------------------------------------------------------

  final Map<AgingBucket, List<MilestoneWithContext>> byBucket =
      <AgingBucket, List<MilestoneWithContext>>{
    for (final AgingBucket bucket in AgingBucket.values)
      bucket: <MilestoneWithContext>[],
  };
  for (final MilestoneWithContext item in live) {
    final AgingBucket bucket =
        AgingBucket.forDaysOverdue(item.milestone.daysOverdueAsOf(asOf));
    byBucket[bucket]!.add(item);
  }

  final List<AgingBand> aging = <AgingBand>[
    for (final AgingBucket bucket in AgingBucket.values)
      AgingBand(
        bucket: bucket,
        amount: MoneyBag.of(
          byBucket[bucket]!.map((MilestoneWithContext m) => m.milestone.outstanding),
        ),
        milestoneCount: byBucket[bucket]!.length,
      ),
  ];

  // --- Per-source breakdown ------------------------------------------------

  final Map<String, List<MilestoneWithContext>> bySourceId =
      <String, List<MilestoneWithContext>>{};
  for (final MilestoneWithContext item in live) {
    bySourceId
        .putIfAbsent(item.milestone.sourceId, () => <MilestoneWithContext>[])
        .add(item);
  }

  final List<SourceBreakdown> breakdowns = bySourceId.entries
      .map((MapEntry<String, List<MilestoneWithContext>> entry) {
    final List<MilestoneWithContext> items = entry.value;
    final List<MilestoneWithContext> late = items
        .where((MilestoneWithContext m) => m.milestone.isOverdueAsOf(asOf))
        .toList();
    return SourceBreakdown(
      sourceId: entry.key,
      displayName: sourceNames[entry.key] ?? entry.key,
      outstanding: MoneyBag.of(
        items.map((MilestoneWithContext m) => m.milestone.outstanding),
      ),
      overdue: MoneyBag.of(
        late.map((MilestoneWithContext m) => m.milestone.outstanding),
      ),
      milestoneCount: items.length,
      overdueCount: late.length,
    );
  }).toList()
    ..sort((SourceBreakdown a, SourceBreakdown b) {
      // Ranking a multi-currency total needs one yardstick; the count of
      // unsettled milestones is currency-free and close enough to "who owes me
      // the most attention". Ties fall back to the channel name.
      final int byCount = b.milestoneCount.compareTo(a.milestoneCount);
      if (byCount != 0) return byCount;
      return a.displayName.compareTo(b.displayName);
    });

  return DashboardSummary(
    asOf: asOf,
    totalOutstanding: MoneyBag.of(
      live.map((MilestoneWithContext m) => m.milestone.outstanding),
    ),
    totalOverdue: MoneyBag.of(
      overdue.map((MilestoneWithContext m) => m.milestone.outstanding),
    ),
    openMilestoneCount: live.length,
    overdueMilestoneCount: overdue.length,
    clientCount:
        live.map((MilestoneWithContext m) => m.client.id).toSet().length,
    overdueClientCount:
        overdue.map((MilestoneWithContext m) => m.client.id).toSet().length,
    bySource: breakdowns,
    aging: aging,
    overdueMilestones: overdue,
  );
}
