import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../domain/calendar.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/entities/payment_source.dart';
import '../../domain/entities/project.dart';
import '../../domain/money.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../providers/ledger_providers.dart';
import '../widgets/common.dart';

/// Add or edit a milestone — the screen where money actually enters the app.
class MilestoneFormScreen extends ConsumerStatefulWidget {
  const MilestoneFormScreen({
    required this.project,
    super.key,
    this.existing,
  });

  final Project project;

  /// Null when adding.
  final Milestone? existing;

  @override
  ConsumerState<MilestoneFormScreen> createState() =>
      _MilestoneFormScreenState();
}

class _MilestoneFormScreenState extends ConsumerState<MilestoneFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _commission;
  late final TextEditingController _tds;
  late final TextEditingController _invoiceRef;
  late final TextEditingController _notes;

  late String _currency;
  late String _sourceId;
  late DateTime _dueDate;
  late MilestoneStage _stage;
  bool _saving = false;

  /// True until the user edits the rate fields themselves.
  ///
  /// While it holds, picking a different source refreshes the rates — which is
  /// what someone switching from Direct to Fiverr expects. Once they have
  /// typed their own rate, changing the source must not silently discard it.
  bool _ratesFollowSource = true;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final Milestone? existing = widget.existing;
    _title = TextEditingController(text: existing?.title ?? '');
    _amount = TextEditingController(
      text: existing == null ? '' : existing.grossAmount.toDecimalString(),
    );
    _commission = TextEditingController(
      text: _bpsToPercentText(existing?.commissionRateBps ?? 0),
    );
    _tds = TextEditingController(
      text: _bpsToPercentText(existing?.tdsRateBps ?? 0),
    );
    _invoiceRef = TextEditingController(text: existing?.invoiceRef ?? '');
    _notes = TextEditingController(text: existing?.notes ?? '');

    _currency = existing?.currency ?? widget.project.defaultCurrency;
    _sourceId = existing?.sourceId ?? widget.project.defaultSourceId;
    _dueDate = existing?.dueDate ?? today().add(const Duration(days: 15));
    _stage = existing?.stage ?? MilestoneStage.invoiced;
    // An existing milestone already carries its snapshotted rates; never let
    // a source change overwrite them behind the user's back.
    _ratesFollowSource = !_isEditing;
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _commission.dispose();
    _tds.dispose();
    _invoiceRef.dispose();
    _notes.dispose();
    super.dispose();
  }

  /// Copies the chosen source's rates into the fields, if the user has not
  /// overridden them.
  void _applySourceDefaults(List<PaymentSource> sources) {
    if (!_ratesFollowSource) return;
    final PaymentSource? source = sources
        .where((PaymentSource s) => s.id == _sourceId)
        .firstOrNull;
    if (source == null) return;
    final String commission = _bpsToPercentText(source.commissionRateBps);
    final String tds = _bpsToPercentText(source.defaultTdsRateBps);
    if (_commission.text != commission) _commission.text = commission;
    if (_tds.text != tds) _tds.text = tds;
  }

  Money? get _grossAmount => Money.tryParse(_amount.text, _currency);
  int get _commissionBps => _percentTextToBps(_commission.text) ?? 0;
  int get _tdsBps => _percentTextToBps(_tds.text) ?? 0;

  Future<void> _pickDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      // Wide enough for backdated work and long retainers, narrow enough that
      // a mistyped year is obvious.
      firstDate: DateTime(today().year - 5),
      lastDate: DateTime(today().year + 5),
      helpText: 'Payment due date',
    );
    if (picked != null) setState(() => _dueDate = dateOnly(picked));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final Money? gross = _grossAmount;
    if (gross == null) return;

    setState(() => _saving = true);
    final LedgerRepository repo = ref.read(ledgerRepositoryProvider);
    final MilestoneDraft draft = MilestoneDraft(
      projectId: widget.project.id,
      title: _title.text,
      grossAmount: gross,
      dueDate: _dueDate,
      sourceId: _sourceId,
      commissionRateBps: _commissionBps,
      tdsRateBps: _tdsBps,
      stage: _stage,
      invoiceRef: _invoiceRef.text,
      invoicedAt: _stage == MilestoneStage.invoiced
          ? (widget.existing?.invoicedAt ?? DateTime.now())
          : null,
      notes: _notes.text,
    );

    try {
      if (_isEditing) {
        await repo.updateMilestone(widget.existing!.id, draft);
      } else {
        await repo.createMilestone(draft);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      showSnack(context, _isEditing ? 'Milestone updated' : 'Milestone added');
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showSnack(context, 'Could not save: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<PaymentSource>> sources =
        ref.watch(paymentSourcesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit milestone' : 'New milestone'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: <Widget>[
            Text(
              widget.project.name,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _title,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'What is this for? *',
                hintText: 'Phase 1, September retainer…',
              ),
              validator: (String? value) =>
                  (value == null || value.trim().isEmpty)
                      ? 'A description is required'
                      : null,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _amount,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Amount billed *',
                      helperText: 'Before commission and TDS',
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (String? value) {
                      final Money? parsed =
                          Money.tryParse(value ?? '', _currency);
                      if (parsed == null) return 'Enter an amount';
                      if (!parsed.isPositive) {
                        return 'Must be more than zero';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _currency,
                    decoration: const InputDecoration(labelText: 'Currency'),
                    items: <DropdownMenuItem<String>>[
                      for (final String currency in kSupportedCurrencies)
                        DropdownMenuItem<String>(
                          value: currency,
                          child: Text(currency),
                        ),
                    ],
                    onChanged: (String? value) {
                      if (value != null) setState(() => _currency = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AsyncView<List<PaymentSource>>(
              value: sources,
              loading: const LinearProgressIndicator(),
              builder: (BuildContext context, List<PaymentSource> data) {
                // Applied during build so the rate fields track the source
                // picker without an extra round trip through setState.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _applySourceDefaults(data);
                });
                final bool known =
                    data.any((PaymentSource s) => s.id == _sourceId);
                return DropdownButtonFormField<String>(
                  initialValue: known ? _sourceId : null,
                  decoration: const InputDecoration(
                    labelText: 'Source *',
                    helperText: 'Where this money comes from',
                  ),
                  items: <DropdownMenuItem<String>>[
                    for (final PaymentSource source in data)
                      DropdownMenuItem<String>(
                        value: source.id,
                        child: Text(source.displayName),
                      ),
                  ],
                  onChanged: (String? value) {
                    if (value == null) return;
                    setState(() => _sourceId = value);
                    _applySourceDefaults(data);
                  },
                  validator: (String? value) =>
                      value == null ? 'Pick a source' : null,
                );
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDueDate,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Due date *',
                  helperText: describeDue(_previewMilestone(), today()),
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                child: Text(formatDate(_dueDate)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _commission,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Commission',
                      suffixText: '%',
                    ),
                    onChanged: (_) => setState(() => _ratesFollowSource = false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _tds,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'TDS',
                      suffixText: '%',
                    ),
                    onChanged: (_) => setState(() => _ratesFollowSource = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _NetPreview(milestone: _previewMilestone()),
            const SectionHeader('STATUS'),
            SegmentedButton<MilestoneStage>(
              segments: const <ButtonSegment<MilestoneStage>>[
                ButtonSegment<MilestoneStage>(
                  value: MilestoneStage.pending,
                  label: Text('Not billed'),
                ),
                ButtonSegment<MilestoneStage>(
                  value: MilestoneStage.invoiced,
                  label: Text('Invoiced'),
                ),
                ButtonSegment<MilestoneStage>(
                  value: MilestoneStage.cancelled,
                  label: Text('Cancelled'),
                ),
              ],
              selected: <MilestoneStage>{_stage},
              onSelectionChanged: (Set<MilestoneStage> selection) =>
                  setState(() => _stage = selection.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _invoiceRef,
              decoration: const InputDecoration(
                labelText: 'Invoice reference',
                hintText: 'INV-2026-014',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notes,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Notes',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_isEditing ? 'Save changes' : 'Add milestone'),
            ),
          ],
        ),
      ),
    );
  }

  /// An in-memory milestone reflecting the current form state.
  ///
  /// Reusing the real entity for the preview means the number shown here is
  /// produced by exactly the same code that will compute it after saving —
  /// there is no second, drifting implementation of the net calculation.
  Milestone _previewMilestone() {
    final Money gross =
        _grossAmount ?? Money.zero(_currency);
    return Milestone(
      id: widget.existing?.id ?? 'preview',
      projectId: widget.project.id,
      title: _title.text,
      grossAmount: gross,
      dueDate: _dueDate,
      sourceId: _sourceId,
      commissionRateBps: _commissionBps,
      tdsRateBps: _tdsBps,
      stage: _stage,
      amountPaid: Money.zero(gross.currency),
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

/// Live breakdown of what will actually be received.
class _NetPreview extends StatelessWidget {
  const _NetPreview({required this.milestone});

  final Milestone milestone;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasDeductions = milestone.commissionRateBps > 0 ||
        milestone.tdsRateBps > 0;

    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                label:
                    'Platform commission (${formatRate(milestone.commissionRateBps)})',
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
            if (hasDeductions) const Divider(),
            DetailRow(
              label: hasDeductions ? 'You receive' : 'You receive (no deductions)',
              emphasised: true,
              value: MoneyText(milestone.netAmount),
            ),
          ],
        ),
      ),
    );
  }
}

String _bpsToPercentText(int basisPoints) {
  if (basisPoints == 0) return '0';
  if (basisPoints % 100 == 0) return '${basisPoints ~/ 100}';
  return (basisPoints / 100)
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

/// Turns `12.5` into 1250 basis points, rounding half-up at two decimals.
int? _percentTextToBps(String text) {
  final String cleaned = text.trim();
  if (cleaned.isEmpty) return 0;
  final double? percent = double.tryParse(cleaned);
  if (percent == null || percent < 0) return null;
  return (percent * 100).round();
}
