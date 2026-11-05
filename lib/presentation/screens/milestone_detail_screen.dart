import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../domain/calendar.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../providers/ledger_providers.dart';
import '../widgets/common.dart';
import 'milestone_form_screen.dart';
import 'record_payment_sheet.dart';

/// One milestone: what it is worth, what has arrived, and what is still owed.
class MilestoneDetailScreen extends ConsumerWidget {
  const MilestoneDetailScreen({required this.milestoneId, super.key});

  final String milestoneId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Milestone?> milestone =
        ref.watch(milestoneProvider(milestoneId));

    return AsyncView<Milestone?>(
      value: milestone,
      loading: const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      builder: (BuildContext context, Milestone? data) {
        if (data == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Milestone removed',
              message: 'This milestone no longer exists.',
            ),
          );
        }
        return _MilestoneDetailView(milestone: data);
      },
    );
  }
}

class _MilestoneDetailView extends ConsumerWidget {
  const _MilestoneDetailView({required this.milestone});

  final Milestone milestone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final DateTime now = today();
    final AsyncValue<List<Payment>> payments =
        ref.watch(milestonePaymentsProvider(milestone.id));
    final bool settled = milestone.isFullyPaid || milestone.isCancelled;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Milestone'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String action) => _onAction(context, ref, action),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Edit milestone'),
                ),
              ),
              if (milestone.stage == MilestoneStage.pending)
                const PopupMenuItem<String>(
                  value: 'invoiced',
                  child: ListTile(
                    leading: Icon(Icons.send_outlined),
                    title: Text('Mark as invoiced'),
                  ),
                ),
              if (!milestone.isCancelled)
                const PopupMenuItem<String>(
                  value: 'cancel',
                  child: ListTile(
                    leading: Icon(Icons.block_outlined),
                    title: Text('Cancel / write off'),
                  ),
                ),
              if (milestone.isCancelled)
                const PopupMenuItem<String>(
                  value: 'reopen',
                  child: ListTile(
                    leading: Icon(Icons.restart_alt),
                    title: Text('Reopen'),
                  ),
                ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline),
                  title: Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: settled
          ? null
          : FloatingActionButton.extended(
              onPressed: () =>
                  showRecordPaymentSheet(context, milestone: milestone),
              icon: const Icon(Icons.payments_outlined),
              label: const Text('Record payment'),
            ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  milestone.title,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              const SizedBox(width: 12),
              StatusChip(milestone.statusAsOf(now)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            describeDue(milestone, now),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: milestone.isOverdueAsOf(now)
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight:
                  milestone.isOverdueAsOf(now) ? FontWeight.w600 : null,
            ),
          ),
          const SectionHeader('AMOUNTS'),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                children: <Widget>[
                  DetailRow(
                    label: 'Billed to client',
                    value: MoneyText(
                      milestone.grossAmount,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  if (milestone.commissionRateBps > 0)
                    DetailRow(
                      label: 'Platform commission '
                          '(${formatRate(milestone.commissionRateBps)})',
                      value: MoneyText(
                        -milestone.commission,
                        style: theme.textTheme.bodyLarge,
                        muted: true,
                      ),
                    ),
                  if (milestone.tdsRateBps > 0)
                    DetailRow(
                      label: 'TDS (${formatRate(milestone.tdsRateBps)})',
                      value: MoneyText(
                        -milestone.tds,
                        style: theme.textTheme.bodyLarge,
                        muted: true,
                      ),
                    ),
                  const Divider(),
                  DetailRow(
                    label: 'Expected in your account',
                    value: MoneyText(
                      milestone.netAmount,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  DetailRow(
                    label: 'Received so far',
                    value: MoneyText(
                      milestone.amountPaid,
                      style: theme.textTheme.bodyLarge,
                      muted: milestone.amountPaid.isZero,
                    ),
                  ),
                  const Divider(),
                  DetailRow(
                    label: 'Still outstanding',
                    emphasised: true,
                    value: MoneyText(milestone.outstanding),
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader('DETAILS'),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                children: <Widget>[
                  DetailRow(
                    label: 'Due date',
                    value: Text(formatDate(milestone.dueDate)),
                  ),
                  DetailRow(
                    label: 'Stage',
                    value: Text(describeStage(milestone.stage)),
                  ),
                  if (milestone.invoicedAt != null)
                    DetailRow(
                      label: 'Invoiced on',
                      value: Text(formatDate(milestone.invoicedAt!)),
                    ),
                  if (milestone.invoiceRef != null)
                    DetailRow(
                      label: 'Invoice reference',
                      value: Text(milestone.invoiceRef!),
                    ),
                  if (milestone.paidAt != null)
                    DetailRow(
                      label: 'Settled on',
                      value: Text(formatDate(milestone.paidAt!)),
                    ),
                  if (milestone.notes != null)
                    DetailRow(
                      label: 'Notes',
                      value: Flexible(child: Text(milestone.notes!)),
                    ),
                ],
              ),
            ),
          ),
          const SectionHeader('PAYMENTS RECEIVED'),
          AsyncView<List<Payment>>(
            value: payments,
            builder: (BuildContext context, List<Payment> data) {
              if (data.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Nothing received yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: <Widget>[
                    for (int i = 0; i < data.length; i++) ...<Widget>[
                      if (i > 0) const Divider(height: 1),
                      _PaymentTile(payment: data[i]),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
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
        final Project? project = await repo.getProject(milestone.projectId);
        if (project == null || !context.mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => MilestoneFormScreen(
              project: project,
              existing: milestone,
            ),
          ),
        );

      case 'invoiced':
        await repo.setMilestoneStage(milestone.id, MilestoneStage.invoiced);
        if (!context.mounted) return;
        showSnack(context, 'Marked as invoiced');

      case 'cancel':
        final bool ok = await confirm(
          context,
          title: 'Cancel this milestone?',
          message: 'It stays on record but drops out of every total and '
              'stops appearing in reminders.',
          confirmLabel: 'Cancel milestone',
        );
        if (!ok) return;
        await repo.setMilestoneStage(milestone.id, MilestoneStage.cancelled);

      case 'reopen':
        await repo.setMilestoneStage(milestone.id, MilestoneStage.invoiced);

      case 'delete':
        final bool ok = await confirm(
          context,
          title: 'Delete this milestone?',
          message: 'Its payment history goes too. Cancel it instead if you '
              'want to keep the record.',
        );
        if (!ok || !context.mounted) return;
        await repo.deleteMilestone(milestone.id);
        if (!context.mounted) return;
        Navigator.of(context).pop();
    }
  }
}

class _PaymentTile extends ConsumerWidget {
  const _PaymentTile({required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final List<String> details = <String>[
      describePaymentMethod(payment.method),
      if (payment.reference != null) payment.reference!,
      // Only worth showing when it was not typed in by hand — this is the
      // audit trail for Module 3's automatic matches.
      if (payment.ingestSource != IngestSource.manual)
        describeIngestSource(payment.ingestSource),
    ];

    return ListTile(
      title: MoneyText(payment.amount, style: theme.textTheme.bodyLarge),
      subtitle: Text('${formatDate(payment.receivedAt)} · ${details.join(' · ')}'),
      trailing: IconButton(
        tooltip: 'Remove payment',
        icon: const Icon(Icons.delete_outline),
        onPressed: () async {
          final bool ok = await confirm(
            context,
            title: 'Remove this payment?',
            message:
                'The milestone will reopen for ${formatMoney(payment.amount)}.',
            confirmLabel: 'Remove',
          );
          if (!ok) return;
          await ref.read(ledgerRepositoryProvider).deletePayment(payment.id);
        },
      ),
    );
  }
}
