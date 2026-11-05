import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/ledger_repository.dart';
import '../providers/ledger_providers.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'client_detail_screen.dart';
import 'client_form_screen.dart';

/// Home: every client, worst debtor first.
class ClientListScreen extends ConsumerWidget {
  const ClientListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ClientSummary>> summaries =
        ref.watch(clientSummariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Archived clients',
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const _ArchivedClientsScreen(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const ClientFormScreen(),
          ),
        ),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Add client'),
      ),
      body: AsyncView<List<ClientSummary>>(
        value: summaries,
        builder: (BuildContext context, List<ClientSummary> data) {
          if (data.isEmpty) {
            return EmptyState(
              icon: Icons.people_outline,
              title: 'No clients yet',
              message:
                  'Add the people and companies you invoice. Projects and '
                  'milestones live under each one.',
              action: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const ClientFormScreen(),
                  ),
                ),
                icon: const Icon(Icons.person_add_alt),
                label: const Text('Add your first client'),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: data.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) =>
                ClientSummaryCard(summary: data[index]),
          );
        },
      ),
    );
  }
}

/// One row of the client list.
class ClientSummaryCard extends StatelessWidget {
  const ClientSummaryCard({required this.summary, super.key});

  final ClientSummary summary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final StatusColors status = context.statusColors;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                ClientDetailScreen(clientId: summary.client.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                backgroundColor: summary.hasOverdue
                    ? status.overdueContainer
                    : theme.colorScheme.secondaryContainer,
                foregroundColor: summary.hasOverdue
                    ? status.onOverdueContainer
                    : theme.colorScheme.onSecondaryContainer,
                child: Text(summary.client.initials),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      summary.client.displayName,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle(summary),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: summary.hasOverdue
                            ? status.onOverdueContainer
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight:
                            summary.hasOverdue ? FontWeight.w600 : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              MoneyBagText(
                summary.outstanding,
                emptyLabel: 'Settled',
                muted: summary.outstanding.isEmpty,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _subtitle(ClientSummary summary) {
    if (summary.overdueMilestoneCount > 0) {
      final String plural =
          summary.overdueMilestoneCount == 1 ? 'milestone' : 'milestones';
      return '${summary.overdueMilestoneCount} $plural overdue · '
          'oldest ${summary.maxDaysOverdue} days';
    }
    if (summary.openMilestoneCount > 0) {
      final String plural =
          summary.openMilestoneCount == 1 ? 'milestone' : 'milestones';
      return '${summary.openMilestoneCount} open $plural';
    }
    return 'Nothing outstanding';
  }
}

/// Archived clients, kept reachable so nothing is ever truly lost from view.
class _ArchivedClientsScreen extends ConsumerWidget {
  const _ArchivedClientsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ClientSummary>> all =
        ref.watch(archivedClientSummariesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Archived clients')),
      body: AsyncView<List<ClientSummary>>(
        value: all,
        builder: (BuildContext context, List<ClientSummary> data) {
          final List<ClientSummary> archived = data
              .where((ClientSummary s) => s.client.isArchived)
              .toList();
          if (archived.isEmpty) {
            return const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Nothing archived',
              message:
                  'Archiving a client hides them from the list but keeps their '
                  'history for your records and tax export.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: archived.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) =>
                ClientSummaryCard(summary: archived[index]),
          );
        },
      ),
    );
  }
}
