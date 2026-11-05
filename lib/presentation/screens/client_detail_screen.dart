import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../domain/calendar.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../providers/ledger_providers.dart';
import '../widgets/common.dart';
import 'client_form_screen.dart';
import 'invoice_screen.dart';
import 'milestone_detail_screen.dart';
import 'milestone_form_screen.dart';
import 'project_form_screen.dart';

/// One client: their totals, their projects, and every milestone under them.
class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({required this.clientId, super.key});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Client?> client = ref.watch(clientProvider(clientId));

    return AsyncView<Client?>(
      value: client,
      loading: const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      builder: (BuildContext context, Client? data) {
        if (data == null) {
          // Reached when the client is deleted while this screen is open.
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              icon: Icons.person_off_outlined,
              title: 'Client removed',
              message: 'This client no longer exists.',
            ),
          );
        }
        return _ClientDetailView(client: data);
      },
    );
  }
}

class _ClientDetailView extends ConsumerWidget {
  const _ClientDetailView({required this.client});

  final Client client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ProjectSummary>> projects =
        ref.watch(projectSummariesProvider(client.id));
    final AsyncValue<List<MilestoneWithContext>> milestones =
        ref.watch(clientMilestonesProvider(client.id));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(client.name),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (String action) =>
                  _onAction(context, ref, action),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Edit client'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'invoice',
                  child: ListTile(
                    leading: Icon(Icons.receipt_long_outlined),
                    title: Text('Create invoice'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'statement',
                  child: ListTile(
                    leading: Icon(Icons.description_outlined),
                    title: Text('Client statement'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'archive',
                  child: ListTile(
                    leading: Icon(
                      client.isArchived
                          ? Icons.unarchive_outlined
                          : Icons.archive_outlined,
                    ),
                    title: Text(client.isArchived ? 'Unarchive' : 'Archive'),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline),
                    title: Text('Delete permanently'),
                  ),
                ),
              ],
            ),
          ],
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Projects'),
              Tab(text: 'Milestones'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) =>
                  ProjectFormScreen(clientId: client.id),
            ),
          ),
          icon: const Icon(Icons.create_new_folder_outlined),
          label: const Text('Add project'),
        ),
        body: Column(
          children: <Widget>[
            _ClientHeader(client: client),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  _ProjectsTab(projects: projects, clientId: client.id),
                  _MilestonesTab(milestones: milestones),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final LedgerRepository repo = ref.read(ledgerRepositoryProvider);

    switch (action) {
      case 'edit':
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                ClientFormScreen(existing: client),
          ),
        );

      case 'invoice':
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => InvoiceScreen(client: client),
          ),
        );

      case 'statement':
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => StatementScreen(client: client),
          ),
        );

      case 'archive':
        await repo.setClientArchived(client.id, !client.isArchived);
        if (!context.mounted) return;
        showSnack(
          context,
          client.isArchived ? 'Client restored' : 'Client archived',
        );

      case 'delete':
        final bool ok = await confirm(
          context,
          title: 'Delete ${client.name}?',
          message: 'Their projects, milestones and payment history go too. '
              'This cannot be undone — archive instead if you only want them '
              'out of the list.',
        );
        if (!ok || !context.mounted) return;
        await repo.deleteClient(client.id);
        if (!context.mounted) return;
        Navigator.of(context).pop();
    }
  }
}

/// Outstanding and overdue totals, plus contact details.
class _ClientHeader extends StatelessWidget {
  const _ClientHeader({required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<String> contact = <String>[
      if (client.company != null) client.company!,
      if (client.email != null) client.email!,
      if (client.phone != null) client.phone!,
    ];

    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (client.isArchived)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Archived',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          if (contact.isNotEmpty)
            Text(
              contact.join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          if (client.notes != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(client.notes!, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _ProjectsTab extends StatelessWidget {
  const _ProjectsTab({required this.projects, required this.clientId});

  final AsyncValue<List<ProjectSummary>> projects;
  final String clientId;

  @override
  Widget build(BuildContext context) {
    return AsyncView<List<ProjectSummary>>(
      value: projects,
      builder: (BuildContext context, List<ProjectSummary> data) {
        if (data.isEmpty) {
          return EmptyState(
            icon: Icons.folder_open_outlined,
            title: 'No projects yet',
            message: 'A project groups the milestones you bill for this client.',
            action: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      ProjectFormScreen(clientId: clientId),
                ),
              ),
              icon: const Icon(Icons.create_new_folder_outlined),
              label: const Text('Add a project'),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          itemCount: data.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (BuildContext context, int index) =>
              _ProjectCard(summary: data[index]),
        );
      },
    );
  }
}

class _ProjectCard extends ConsumerWidget {
  const _ProjectCard({required this.summary});

  final ProjectSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<Milestone>> milestones =
        ref.watch(projectMilestonesProvider(summary.project.id));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 6, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        summary.project.name,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _projectSubtitle(summary),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    MoneyBagText(
                      summary.outstanding,
                      emptyLabel: 'Settled',
                      style: theme.textTheme.titleSmall,
                      muted: summary.outstanding.isEmpty,
                    ),
                    Text(
                      'outstanding',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  onSelected: (String action) async {
                    final LedgerRepository repo =
                        ref.read(ledgerRepositoryProvider);
                    switch (action) {
                      case 'edit':
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                ProjectFormScreen(
                              clientId: summary.project.clientId,
                              existing: summary.project,
                            ),
                          ),
                        );
                      case 'archive':
                        await repo.setProjectArchived(
                          summary.project.id,
                          !summary.project.isArchived,
                        );
                      case 'delete':
                        final bool ok = await confirm(
                          context,
                          title: 'Delete ${summary.project.name}?',
                          message:
                              'Its ${summary.milestoneCount} milestone(s) and '
                              'their payment history go too.',
                        );
                        if (!ok) return;
                        await repo.deleteProject(summary.project.id);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit project'),
                    ),
                    PopupMenuItem<String>(
                      value: 'archive',
                      child: Text(
                        summary.project.isArchived ? 'Unarchive' : 'Archive',
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AsyncView<List<Milestone>>(
            value: milestones,
            loading: const SizedBox(height: 4),
            builder: (BuildContext context, List<Milestone> data) {
              return Column(
                children: <Widget>[
                  for (final Milestone milestone in data)
                    MilestoneTile(milestone: milestone),
                  if (data.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                      child: Text(
                        'No milestones yet.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const Divider(height: 1),
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) =>
                    MilestoneFormScreen(project: summary.project),
              ),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add milestone'),
          ),
        ],
      ),
    );
  }

  static String _projectSubtitle(ProjectSummary summary) {
    final List<String> parts = <String>[
      '${summary.milestoneCount} milestone${summary.milestoneCount == 1 ? '' : 's'}',
      if (summary.overdueMilestoneCount > 0)
        '${summary.overdueMilestoneCount} overdue',
      if (summary.project.isArchived) 'archived',
    ];
    return parts.join(' · ');
  }
}

/// A single milestone row, used inside project cards and the milestones tab.
class MilestoneTile extends StatelessWidget {
  const MilestoneTile({
    required this.milestone,
    super.key,
    this.subtitlePrefix,
  });

  final Milestone milestone;

  /// Extra context, e.g. the project name when the row is shown outside it.
  final String? subtitlePrefix;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateTime now = today();
    final String due = describeDue(milestone, now);

    return ListTile(
      dense: true,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              MilestoneDetailScreen(milestoneId: milestone.id),
        ),
      ),
      title: Text(
        milestone.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(
          decoration: milestone.isCancelled ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        subtitlePrefix == null ? due : '$subtitlePrefix · $due',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          MoneyText(
            milestone.isFullyPaid || milestone.isCancelled
                ? milestone.netAmount
                : milestone.outstanding,
            style: theme.textTheme.titleSmall,
            muted: milestone.isCancelled,
          ),
          const SizedBox(height: 4),
          StatusChip(milestone.statusAsOf(now), dense: true),
        ],
      ),
    );
  }
}

class _MilestonesTab extends StatelessWidget {
  const _MilestonesTab({required this.milestones});

  final AsyncValue<List<MilestoneWithContext>> milestones;

  @override
  Widget build(BuildContext context) {
    return AsyncView<List<MilestoneWithContext>>(
      value: milestones,
      builder: (BuildContext context, List<MilestoneWithContext> data) {
        if (data.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No milestones yet',
            message:
                'Milestones are the amounts you actually bill. Add a project, '
                'then add milestones to it.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 96),
          itemCount: data.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (BuildContext context, int index) => MilestoneTile(
            milestone: data[index].milestone,
            subtitlePrefix: data[index].project.name,
          ),
        );
      },
    );
  }
}
