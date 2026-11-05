import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../data/ingest/payment_classifier.dart';
import '../../domain/calendar.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/entities/payment.dart';
import '../../domain/ingest/payment_event.dart';
import '../../domain/ingest/reconciliation.dart';
import '../../domain/repositories/ingest_repository.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../providers/app_providers.dart';
import '../providers/ledger_providers.dart';
import '../widgets/common.dart';
import 'data_sources_screen.dart';

/// Payments the app found, waiting for the user to confirm them.
///
/// The deliberate speed bump between automated parsing and the ledger. A regex
/// against a push notification is a guess; this screen is where a guess becomes
/// a financial record, and only a person can make that promotion.
class ReviewQueueScreen extends ConsumerWidget {
  const ReviewQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<IngestedEvent>> pending =
        ref.watch(pendingIngestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review payments'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Data sources',
            icon: const Icon(Icons.cloud_sync_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const DataSourcesScreen(),
              ),
            ),
          ),
        ],
      ),
      body: AsyncView<List<IngestedEvent>>(
        value: pending,
        builder: (BuildContext context, List<IngestedEvent> data) {
          if (data.isEmpty) {
            return EmptyState(
              icon: Icons.inbox_outlined,
              title: 'Nothing to review',
              message: 'Payments found in statements, platform emails and app '
                  'notifications appear here before they reach the ledger.',
              action: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        const DataSourcesScreen(),
                  ),
                ),
                icon: const Icon(Icons.add_link),
                label: const Text('Connect a source'),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            itemCount: data.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) =>
                _IngestEventCard(entry: data[index]),
          );
        },
      ),
    );
  }
}

class _IngestEventCard extends ConsumerWidget {
  const _IngestEventCard({required this.entry});

  final IngestedEvent entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        entry.event.description ??
                            entry.event.clientHint ??
                            'Payment received',
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${formatDate(entry.event.occurredAt)} · '
                        '${describeIngestSource(entry.event.channel)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _KindChip(classification: classifyEvent(entry.event)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    MoneyText(entry.event.amountToRecord),
                    if (entry.event.netAmount != null &&
                        entry.event.netAmount != entry.event.grossAmount)
                      Text(
                        '${formatMoney(entry.event.grossAmount)} gross',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (entry.event.externalTxnId != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                'Ref ${entry.event.externalTxnId}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () async {
                    await ref
                        .read(ingestRepositoryProvider)
                        .ignoreEvent(entry.id);
                    if (!context.mounted) return;
                    showSnack(context, 'Dismissed');
                  },
                  child: const Text('Not a payment'),
                ),
                const SizedBox(width: 4),
                FilledButton.tonal(
                  onPressed: () => showMatchSheet(context, entry: entry),
                  child: const Text('Match & import'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Picks the milestone an ingested payment belongs to.
Future<void> showMatchSheet(
  BuildContext context, {
  required IngestedEvent entry,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext context) => _MatchSheet(entry: entry),
  );
}

class _MatchSheet extends ConsumerStatefulWidget {
  const _MatchSheet({required this.entry});

  final IngestedEvent entry;

  @override
  ConsumerState<_MatchSheet> createState() => _MatchSheetState();
}

class _MatchSheetState extends ConsumerState<_MatchSheet> {
  String? _selectedMilestoneId;
  bool _saving = false;
  PaymentKind? _kind;
  DateTime? _dueDate;

  PaymentClassification get _classification =>
      classifyEvent(widget.entry.event);

  /// The chosen kind, defaulting to the classifier's guess the first time.
  PaymentKind get _effectiveKind => _kind ??= _classification.kind;

  /// The due date for an "owed" milestone: the one in the mail if any, else a
  /// fortnight out, which the user can change.
  DateTime get _effectiveDueDate =>
      _dueDate ??= _classification.dueDate ??
          dateOnly(widget.entry.event.occurredAt)
              .add(const Duration(days: 15));

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<MilestoneWithContext>> open =
        ref.watch(openMilestonesProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: AsyncView<List<MilestoneWithContext>>(
        value: open,
        builder: (BuildContext context, List<MilestoneWithContext> candidates) {
          final List<MatchSuggestion> suggestions = suggestMatches(
            event: widget.entry.event,
            candidates: candidates,
          );

          // The best-evidenced candidate is preselected only when the evidence
          // is actually strong; otherwise nothing is chosen for the user.
          _selectedMilestoneId ??= suggestions.isNotEmpty &&
                  suggestions.first.isStrong
              ? suggestions.first.candidate.milestone.id
              : null;

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Which milestone is this?',
                    style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  '${formatMoney(widget.entry.event.amountToRecord)} · '
                  '${formatDate(widget.entry.event.occurredAt)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                if (suggestions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No open milestone looks like a match. Record it by hand '
                      'on the right milestone, or dismiss it.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  for (final MatchSuggestion suggestion in suggestions.take(6))
                    _SuggestionTile(
                      suggestion: suggestion,
                      selected: _selectedMilestoneId ==
                          suggestion.candidate.milestone.id,
                      onTap: () => setState(
                        () => _selectedMilestoneId =
                            suggestion.candidate.milestone.id,
                      ),
                    ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _selectedMilestoneId == null || _saving
                      ? null
                      : () => _import(suggestions),
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: const Text('Import this payment'),
                ),
                const Divider(height: 28),
                // Create a brand-new record from the captured data, for when the
                // job was never logged by hand. The app pre-reads whether this is
                // money received or money still owed; the user can flip it.
                Text('Or create a new record',
                    style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                for (final String reason in _classification.reasons.take(2))
                  Text(
                    '• $reason',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 8),
                SegmentedButton<PaymentKind>(
                  segments: const <ButtonSegment<PaymentKind>>[
                    ButtonSegment<PaymentKind>(
                      value: PaymentKind.received,
                      label: Text('Received'),
                      icon: Icon(Icons.south_east, size: 16),
                    ),
                    ButtonSegment<PaymentKind>(
                      value: PaymentKind.owed,
                      label: Text('Still owed'),
                      icon: Icon(Icons.schedule, size: 16),
                    ),
                  ],
                  selected: <PaymentKind>{_effectiveKind},
                  onSelectionChanged: (Set<PaymentKind> s) =>
                      setState(() => _kind = s.first),
                ),
                if (_effectiveKind == PaymentKind.owed)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: const Icon(Icons.event_outlined),
                      title: const Text('Payment due'),
                      trailing: Text(formatDate(_effectiveDueDate)),
                      onTap: _pickDueDate,
                    ),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _saving ? null : _createAndImport,
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  label: Text(
                    _effectiveKind == PaymentKind.owed
                        ? 'Create as a pending milestone'
                        : 'Create client + milestone (paid)',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _effectiveKind == PaymentKind.owed
                      ? 'Creates a client, project and milestone that still owes '
                          'this amount — it shows as pending, and overdue once '
                          'past the due date. No payment is recorded yet.'
                      : 'Creates a client, project and milestone from the '
                          'captured details, then records this payment against '
                          'it as received.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                // The raw source text, so a suspicious figure can be checked
                // against what was actually parsed.
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    'What was captured',
                    style: theme.textTheme.labelLarge,
                  ),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        widget.entry.event.raw,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _import(List<MatchSuggestion> suggestions) async {
    final String? milestoneId = _selectedMilestoneId;
    if (milestoneId == null) return;

    setState(() => _saving = true);
    try {
      await ref.read(ingestRepositoryProvider).importEvent(
            eventId: widget.entry.id,
            milestoneId: milestoneId,
            amount: widget.entry.event.amountToRecord,
            receivedAt: dateOnly(widget.entry.event.occurredAt),
            method: PaymentMethod.platform,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      showSnack(context, 'Payment imported');
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showSnack(context, 'Could not import: $error');
    }
  }

  Future<void> _pickDueDate() async {
    final DateTime initial = _effectiveDueDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(initial.year - 2),
      lastDate: DateTime(initial.year + 3),
    );
    if (picked != null) setState(() => _dueDate = dateOnly(picked));
  }

  /// Builds a client → project → milestone from the captured event.
  ///
  /// When the item is money received, a payment is recorded against the new
  /// milestone so it shows as paid. When it is money still owed, no payment is
  /// recorded and the milestone keeps its outstanding balance — pending now,
  /// overdue once past the due date — ready for the real payment to settle later.
  Future<void> _createAndImport() async {
    final bool owed = _effectiveKind == PaymentKind.owed;
    final DateTime dueDate = _effectiveDueDate;
    setState(() => _saving = true);
    try {
      final PaymentEvent event = widget.entry.event;
      final LedgerRepository ledger = ref.read(ledgerRepositoryProvider);
      final IngestRepository ingest = ref.read(ingestRepositoryProvider);

      // Commission and TDS come from the source's current defaults, exactly as
      // they would for a milestone created by hand on this source.
      final source = await ledger.getSource(event.sourceId);
      final String sourceName = source?.displayName ?? event.sourceId;
      final int commissionBps = source?.commissionRateBps ?? 0;
      final int tdsBps = source?.defaultTdsRateBps ?? 0;

      final String? hintedClient = event.clientHint?.trim();
      final String clientName = hintedClient != null && hintedClient.isNotEmpty
          ? hintedClient
          : 'Imported from $sourceName';

      final String? hintedTitle = event.description?.trim();
      final String title = hintedTitle != null && hintedTitle.isNotEmpty
          ? hintedTitle
          : owed ? 'Invoiced work' : 'Imported payment';

      final String clientId =
          await ledger.createClient(ClientDraft(name: clientName));
      final String projectId = await ledger.createProject(
        ProjectDraft(
          clientId: clientId,
          name: '$sourceName · ${formatDate(dateOnly(event.occurredAt))}',
          defaultSourceId: event.sourceId,
          defaultCurrency: event.currency,
          // The platform's order id, so a future payment for the same job can be
          // matched automatically against this project.
          externalRef: event.projectHint,
        ),
      );
      final String milestoneId = await ledger.createMilestone(
        MilestoneDraft(
          projectId: projectId,
          title: title,
          grossAmount: event.grossAmount,
          // Owed: the stated due date. Received: the date it arrived.
          dueDate: owed ? dueDate : dateOnly(event.occurredAt),
          sourceId: event.sourceId,
          commissionRateBps: commissionBps,
          tdsRateBps: tdsBps,
          stage: MilestoneStage.invoiced,
        ),
      );

      if (owed) {
        // No payment yet — the milestone stays outstanding. Clear the event from
        // the queue so the same invoice is not offered again; the real payment,
        // when it lands, is a separate event that matches this milestone.
        await ingest.ignoreEvent(widget.entry.id);
      } else {
        await ingest.importEvent(
          eventId: widget.entry.id,
          milestoneId: milestoneId,
          amount: event.amountToRecord,
          receivedAt: dateOnly(event.occurredAt),
          method: PaymentMethod.platform,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      showSnack(
        context,
        owed
            ? 'Created "$clientName" as a pending milestone'
            : 'Created "$clientName" and imported the payment',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showSnack(context, 'Could not create: $error');
    }
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.suggestion,
    required this.selected,
    required this.onTap,
  });

  final MatchSuggestion suggestion;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MilestoneWithContext candidate = suggestion.candidate;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
            color: selected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.25)
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      candidate.client.name,
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      '${candidate.project.name} · ${candidate.milestone.title}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // The evidence, in words. A suggestion the user cannot
                    // check is a suggestion they have to take on faith.
                    for (final String reason in suggestion.reasons)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.check,
                            size: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              reason,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              MoneyText(
                candidate.milestone.outstanding,
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The app's read of one captured event — received money or money still owed.
PaymentClassification classifyEvent(PaymentEvent event) => classifyPayment(
      text: '${event.description ?? ''}\n${event.raw}',
      channel: event.channel,
      occurredAt: event.occurredAt,
    );

/// A small badge showing whether an ingested item looks received or owed.
class _KindChip extends StatelessWidget {
  const _KindChip({required this.classification});

  final PaymentClassification classification;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool owed = classification.kind == PaymentKind.owed;
    final Color base =
        owed ? theme.colorScheme.tertiary : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(owed ? Icons.schedule : Icons.south_east, size: 13, color: base),
          const SizedBox(width: 4),
          Text(
            owed ? 'Looks owed' : 'Looks received',
            style: theme.textTheme.labelSmall?.copyWith(
              color: base,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
