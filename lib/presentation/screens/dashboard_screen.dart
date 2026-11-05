import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../domain/aging.dart';
import '../../domain/money.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../providers/dashboard_providers.dart';
import '../theme.dart';
import '../widgets/aging_chart.dart';
import '../widgets/app_logo.dart';
import '../widgets/common.dart';
import 'milestone_detail_screen.dart';

/// The screen that justifies the app: what is owed, by whom, and how late.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  /// Which currency the bar charts are drawn for.
  ///
  /// View state, not app state: it resets with the screen and nothing else
  /// reads it. Null means "use whichever currency has the most outstanding".
  String? _currency;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<DashboardSummary> summary = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        // The home tab carries the brand mark; the other tabs keep plain
        // titles. The bottom bar already labels this destination "Dashboard".
        titleSpacing: 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            AppLogo(size: 28),
            SizedBox(width: 10),
            Text('PayTrail'),
          ],
        ),
      ),
      body: AsyncView<DashboardSummary>(
        value: summary,
        builder: (BuildContext context, DashboardSummary data) {
          if (!data.hasAnythingOutstanding) {
            return const EmptyState(
              icon: Icons.check_circle_outline,
              title: 'Nothing outstanding',
              message:
                  'Every milestone you have recorded is settled or cancelled. '
                  'Add work under a client to start tracking.',
            );
          }

          final List<String> currencies = data.totalOutstanding.currencies;
          final String currency = currencies.contains(_currency)
              ? _currency!
              : currencies.first;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: <Widget>[
              _OutstandingHeader(summary: data),
              if (currencies.length > 1) ...<Widget>[
                const SizedBox(height: 16),
                _CurrencyFilter(
                  currencies: currencies,
                  selected: currency,
                  onChanged: (String value) =>
                      setState(() => _currency = value),
                ),
              ],
              const SectionHeader('AGING'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: AgingChart(bands: data.aging, currency: currency),
                ),
              ),
              const SectionHeader('BY SOURCE'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
                  child: _SourceBreakdownList(
                    breakdowns: data.bySource,
                    currency: currency,
                  ),
                ),
              ),
              SectionHeader(
                'OVERDUE (${data.overdueMilestoneCount})',
              ),
              if (data.overdueMilestones.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: context.statusColors.onPaidContainer,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Nothing is past its due date.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: <Widget>[
                      for (int i = 0;
                          i < data.overdueMilestones.length;
                          i++) ...<Widget>[
                        if (i > 0) const Divider(height: 1),
                        _OverdueTile(
                          item: data.overdueMilestones[i],
                          asOf: data.asOf,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// The hero figure and the two counts that qualify it.
class _OutstandingHeader extends StatelessWidget {
  const _OutstandingHeader({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final StatusColors status = context.statusColors;
    final List<Money> amounts = summary.totalOutstanding.amounts;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Total outstanding',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            // One currency gets the hero treatment; several are stacked at a
            // calmer size, because there is no single number to lead with.
            if (amounts.length == 1)
              Text(
                formatMoney(amounts.single),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final Money amount in amounts)
                    Text(
                      formatMoney(amount),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 10),
            Text(
              '${summary.openMilestoneCount} open '
              '${summary.openMilestoneCount == 1 ? 'milestone' : 'milestones'}'
              ' across ${summary.clientCount} '
              '${summary.clientCount == 1 ? 'client' : 'clients'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (summary.overdueMilestoneCount > 0) ...<Widget>[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: status.overdueContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Icon plus label, never colour alone.
                    Icon(
                      Icons.schedule,
                      size: 18,
                      color: status.onOverdueContainer,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Overdue',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: status.onOverdueContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatMoneyBag(summary.totalOverdue),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: status.onOverdueContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${summary.overdueMilestoneCount} '
                            '${summary.overdueMilestoneCount == 1 ? 'milestone' : 'milestones'}'
                            ' · ${summary.overdueClientCount} '
                            '${summary.overdueClientCount == 1 ? 'client' : 'clients'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: status.onOverdueContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Picks which currency the bar charts below are drawn for.
class _CurrencyFilter extends StatelessWidget {
  const _CurrencyFilter({
    required this.currencies,
    required this.selected,
    required this.onChanged,
  });

  final List<String> currencies;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          'Charts in',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                for (final String currency in currencies)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(currency),
                      selected: currency == selected,
                      onSelected: (_) => onChanged(currency),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Outstanding per payment channel.
///
/// One accent colour for every bar, not a hue per source: each row is already
/// labelled by name, so a categorical palette here would encode nothing that
/// the text does not.
class _SourceBreakdownList extends StatelessWidget {
  const _SourceBreakdownList({
    required this.breakdowns,
    required this.currency,
  });

  final List<SourceBreakdown> breakdowns;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int maxValue = breakdowns.fold<int>(
      0,
      (int worst, SourceBreakdown b) {
        final int value = b.outstanding.inCurrency(currency).minorUnits;
        return value > worst ? value : worst;
      },
    );

    return Column(
      children: <Widget>[
        for (final SourceBreakdown breakdown in breakdowns)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        breakdown.displayName,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    MoneyBagText(
                      breakdown.outstanding,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final int value =
                        breakdown.outstanding.inCurrency(currency).minorUnits;
                    final double fraction =
                        maxValue == 0 ? 0 : value / maxValue;
                    return Stack(
                      children: <Widget>[
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Container(
                          height: 8,
                          width: value == 0
                              ? 0
                              : (constraints.maxWidth * fraction)
                                  .clamp(4.0, constraints.maxWidth),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(2),
                              right: Radius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  breakdown.overdueCount > 0
                      ? '${breakdown.milestoneCount} open · '
                          '${breakdown.overdueCount} overdue'
                      : '${breakdown.milestoneCount} open',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// One line of the chase list.
class _OverdueTile extends StatelessWidget {
  const _OverdueTile({required this.item, required this.asOf});

  final MilestoneWithContext item;
  final DateTime asOf;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int days = item.milestone.daysOverdueAsOf(asOf);

    return ListTile(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              MilestoneDetailScreen(milestoneId: item.milestone.id),
        ),
      ),
      title: Text(
        item.client.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge,
      ),
      subtitle: Text(
        '${item.project.name} · ${item.milestone.title}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          MoneyText(
            item.milestone.outstanding,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 2),
          Text(
            '$days ${days == 1 ? 'day' : 'days'} late',
            style: theme.textTheme.labelSmall?.copyWith(
              color: context.agingColors.forBucket(
                AgingBucket.forDaysOverdue(days),
              ),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

