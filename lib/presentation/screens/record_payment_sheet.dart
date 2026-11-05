import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../domain/calendar.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/entities/payment.dart';
import '../../domain/money.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../providers/ledger_providers.dart';
import '../widgets/common.dart';

/// The mark-as-paid flow.
///
/// Prefilled with the full outstanding balance, because that is the common
/// case — but it is an ordinary editable amount, so recording "client paid
/// half" takes one edit rather than a different screen. Part payments are the
/// norm in freelancing, not an edge case bolted on afterwards.
Future<void> showRecordPaymentSheet(
  BuildContext context, {
  required Milestone milestone,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext context) =>
        _RecordPaymentSheet(milestone: milestone),
  );
}

class _RecordPaymentSheet extends ConsumerStatefulWidget {
  const _RecordPaymentSheet({required this.milestone});

  final Milestone milestone;

  @override
  ConsumerState<_RecordPaymentSheet> createState() =>
      _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends ConsumerState<_RecordPaymentSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _reference;
  late DateTime _receivedAt;
  late PaymentMethod _method;
  bool _saving = false;

  Milestone get _milestone => widget.milestone;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(
      text: _milestone.outstanding.toDecimalString(),
    );
    _reference = TextEditingController();
    _receivedAt = today();
    // A platform milestone almost always settles as a payout; a direct one
    // usually arrives by bank transfer. Guessing right saves a tap.
    _method = _milestone.commissionRateBps > 0
        ? PaymentMethod.platform
        : PaymentMethod.bankTransfer;
  }

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    super.dispose();
  }

  Money? get _parsedAmount =>
      Money.tryParse(_amount.text, _milestone.currency);

  void _setAmount(Money amount) {
    _amount.text = amount.toDecimalString();
    setState(() {});
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _receivedAt,
      firstDate: DateTime(today().year - 5),
      lastDate: today(),
      helpText: 'Date received',
    );
    if (picked != null) setState(() => _receivedAt = dateOnly(picked));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final Money? amount = _parsedAmount;
    if (amount == null) return;

    setState(() => _saving = true);
    final LedgerRepository repo = ref.read(ledgerRepositoryProvider);

    try {
      await repo.addPayment(
        PaymentDraft(
          milestoneId: _milestone.id,
          amount: amount,
          receivedAt: _receivedAt,
          method: _method,
          reference: _reference.text,
        ),
      );
      if (!mounted) return;
      final bool settles =
          amount.minorUnits >= _milestone.outstanding.minorUnits;
      Navigator.of(context).pop();
      showSnack(
        context,
        settles
            ? 'Payment recorded — milestone settled'
            : 'Payment recorded — ${formatMoney((_milestone.outstanding - amount).clampToZero())} still due',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showSnack(context, 'Could not record payment: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Money outstanding = _milestone.outstanding;
    final Money? entered = _parsedAmount;
    final Money remainder = entered == null
        ? outstanding
        : (outstanding - entered).clampToZero();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Record a payment', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${_milestone.title} · ${formatMoney(outstanding)} outstanding',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amount,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: InputDecoration(
                labelText: 'Amount received',
                prefixText: '${_milestone.currency} ',
                helperText: entered == null
                    ? null
                    : (remainder.isZero
                        ? 'Settles this milestone'
                        : '${formatMoney(remainder)} would remain'),
              ),
              onChanged: (_) => setState(() {}),
              validator: (String? value) {
                final Money? parsed =
                    Money.tryParse(value ?? '', _milestone.currency);
                if (parsed == null) return 'Enter an amount';
                if (!parsed.isPositive) return 'Must be more than zero';
                return null;
              },
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: <Widget>[
                ActionChip(
                  label: const Text('Full balance'),
                  onPressed: () => _setAmount(outstanding),
                ),
                ActionChip(
                  label: const Text('Half'),
                  onPressed: () => _setAmount(outstanding.percentage(5000)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Received on',
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(formatDate(_receivedAt)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PaymentMethod>(
              initialValue: _method,
              decoration: const InputDecoration(labelText: 'How it arrived'),
              items: <DropdownMenuItem<PaymentMethod>>[
                for (final PaymentMethod method in PaymentMethod.values)
                  DropdownMenuItem<PaymentMethod>(
                    value: method,
                    child: Text(describePaymentMethod(method)),
                  ),
              ],
              onChanged: (PaymentMethod? value) {
                if (value != null) setState(() => _method = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reference,
              decoration: const InputDecoration(
                labelText: 'Reference',
                hintText: 'UTR, cheque number, payout id…',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: const Text('Record payment'),
            ),
          ],
        ),
      ),
    );
  }
}
