import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../core/formatting.dart';
import '../../domain/calendar.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/export/income_report.dart';
import '../../domain/money_bag.dart';
import '../../domain/repositories/ingest_repository.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../providers/app_providers.dart';
import '../providers/ledger_providers.dart';
import '../widgets/common.dart';

/// Builds a PDF invoice for one client from milestones the user picks.
class InvoiceScreen extends ConsumerStatefulWidget {
  const InvoiceScreen({required this.client, super.key});

  final Client client;

  @override
  ConsumerState<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends ConsumerState<InvoiceScreen> {
  final Set<String> _selected = <String>{};
  bool _busy = false;
  DateTime _issuedOn = today();
  DateTime _dueOn = today().add(const Duration(days: 15));

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<MilestoneWithContext>> milestones =
        ref.watch(clientMilestonesProvider(widget.client.id));

    return Scaffold(
      appBar: AppBar(title: Text('Invoice · ${widget.client.name}')),
      body: AsyncView<List<MilestoneWithContext>>(
        value: milestones,
        builder: (BuildContext context, List<MilestoneWithContext> all) {
          // Cancelled and already-settled work has nothing left to bill.
          final List<MilestoneWithContext> billable = all
              .where((MilestoneWithContext m) =>
                  !m.milestone.isCancelled && !m.milestone.isFullyPaid)
              .toList();

          if (billable.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Nothing to invoice',
              message: 'Every milestone for this client is settled or '
                  'cancelled.',
            );
          }

          final List<MilestoneWithContext> chosen = billable
              .where((MilestoneWithContext m) =>
                  _selected.contains(m.milestone.id))
              .toList();
          final Set<String> currencies = chosen
              .map((MilestoneWithContext m) => m.milestone.currency)
              .toSet();
          final bool mixedCurrencies = currencies.length > 1;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            children: <Widget>[
              Text(
                'Pick the milestones to bill. They must share one currency — '
                'an invoice with two currencies on it is not a document a '
                'client can pay.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SectionHeader('MILESTONES'),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: <Widget>[
                    for (final MilestoneWithContext item in billable)
                      CheckboxListTile(
                        value: _selected.contains(item.milestone.id),
                        onChanged: (bool? on) => setState(() {
                          if (on ?? false) {
                            _selected.add(item.milestone.id);
                          } else {
                            _selected.remove(item.milestone.id);
                          }
                        }),
                        title: Text(item.milestone.title),
                        subtitle: Text(
                          '${item.project.name} · due '
                          '${formatDate(item.milestone.dueDate)}',
                        ),
                        secondary: MoneyText(
                          item.milestone.grossAmount,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                  ],
                ),
              ),
              const SectionHeader('DATES'),
              Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: const Text('Issued'),
                      trailing: Text(formatDate(_issuedOn)),
                      onTap: () async {
                        final DateTime? picked = await _pickDate(_issuedOn);
                        if (picked != null) setState(() => _issuedOn = picked);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Payment due'),
                      trailing: Text(formatDate(_dueOn)),
                      onTap: () async {
                        final DateTime? picked = await _pickDate(_dueOn);
                        if (picked != null) setState(() => _dueOn = picked);
                      },
                    ),
                  ],
                ),
              ),
              if (mixedCurrencies) ...<Widget>[
                const SizedBox(height: 16),
                Card(
                  color: theme.colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.error_outline,
                            color: theme.colorScheme.onErrorContainer),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'The selected milestones are in '
                            '${currencies.join(' and ')}. Raise one invoice '
                            'per currency.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton.icon(
            onPressed: _selected.isEmpty || _busy ? null : _generate,
            icon: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
            label: Text(
              _selected.isEmpty
                  ? 'Select milestones'
                  : 'Generate invoice (${_selected.length})',
            ),
          ),
        ),
      ),
    );
  }

  Future<DateTime?> _pickDate(DateTime initial) => showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(today().year - 2),
        lastDate: DateTime(today().year + 2),
      );

  Future<void> _generate() async {
    setState(() => _busy = true);
    try {
      final List<MilestoneWithContext> all =
          await ref.read(clientMilestonesProvider(widget.client.id).future);
      final List<MilestoneWithContext> chosen = all
          .where((MilestoneWithContext m) => _selected.contains(m.milestone.id))
          .toList();
      if (chosen.isEmpty) return;

      final IngestRepository settings = ref.read(ingestRepositoryProvider);
      final String businessName =
          await settings.getSetting(SettingKeys.invoiceBusinessName) ??
              'Your business';
      final String prefix =
          await settings.getSetting(SettingKeys.invoiceNumberPrefix) ?? 'INV';

      // Numbered from how many invoice references already exist this year, so
      // the sequence survives across sessions without a counter to keep.
      final int issuedThisYear = all
          .where((MilestoneWithContext m) =>
              m.milestone.invoiceRef != null &&
              m.milestone.invoiceRef!.contains('${_issuedOn.year}'))
          .length;

      final InvoiceDocument invoice = InvoiceDocument.fromMilestones(
        number: buildInvoiceNumber(
          sequence: issuedThisYear,
          issuedOn: _issuedOn,
          prefix: prefix,
        ),
        issuedOn: _issuedOn,
        dueOn: _dueOn,
        businessName: businessName,
        businessAddress: await settings.getSetting(SettingKeys.invoiceAddress),
        businessEmail: await settings.getSetting(SettingKeys.invoiceEmail),
        businessPhone: await settings.getSetting(SettingKeys.invoicePhone),
        businessTaxId: await settings.getSetting(SettingKeys.invoiceTaxId),
        clientName: widget.client.name,
        clientCompany: widget.client.company,
        clientEmail: widget.client.email,
        milestones: chosen,
        notes: await settings.getSetting(SettingKeys.invoiceNotes),
      );

      final Uint8List bytes =
          await ref.read(invoicePdfProvider).buildInvoice(invoice);

      if (!mounted) return;
      // The system sheet handles printing, saving and sharing, so the app does
      // not need storage permissions of its own.
      await Printing.sharePdf(
        bytes: bytes,
        filename: '${invoice.number}.pdf',
      );

      // Stamp the invoice reference on each milestone and mark it invoiced, so
      // the reminder engine has a document to quote and a clock to start.
      final LedgerRepository ledger = ref.read(ledgerRepositoryProvider);
      for (final MilestoneWithContext item in chosen) {
        await ledger.updateMilestone(
          item.milestone.id,
          MilestoneDraft(
            projectId: item.milestone.projectId,
            title: item.milestone.title,
            grossAmount: item.milestone.grossAmount,
            dueDate: _dueOn,
            sourceId: item.milestone.sourceId,
            commissionRateBps: item.milestone.commissionRateBps,
            tdsRateBps: item.milestone.tdsRateBps,
            stage: MilestoneStage.invoiced,
            invoiceRef: invoice.number,
            invoicedAt: _issuedOn,
            notes: item.milestone.notes,
          ),
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      showSnack(context, 'Invoice ${invoice.number} generated');
    } catch (error) {
      if (!mounted) return;
      showSnack(context, 'Could not generate: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// A client statement for a date range, as a PDF.
class StatementScreen extends ConsumerStatefulWidget {
  const StatementScreen({required this.client, super.key});

  final Client client;

  @override
  ConsumerState<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends ConsumerState<StatementScreen> {
  DateTimeRange _range = DateTimeRange(
    start: DateTime(today().year, today().month - 5),
    end: today(),
  );
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<IncomeRow>> rows = ref.watch(incomeRowsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Statement · ${widget.client.name}')),
      body: AsyncView<List<IncomeRow>>(
        value: rows,
        builder: (BuildContext context, List<IncomeRow> all) {
          final IncomeReport report = IncomeReport.build(
            rows: all
                .where((IncomeRow row) =>
                    row.context.client.id == widget.client.id)
                .toList(),
            from: _range.start,
            to: _range.end,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: () async {
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(today().year - 10),
                    lastDate: DateTime(today().year + 1, 12, 31),
                    initialDateRange: _range,
                  );
                  if (picked != null) setState(() => _range = picked);
                },
                icon: const Icon(Icons.date_range_outlined, size: 18),
                label: Text(
                  '${formatDate(_range.start)} – ${formatDate(_range.end)}',
                ),
              ),
              const SectionHeader('IN THIS PERIOD'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: <Widget>[
                      DetailRow(
                        label: 'Payments received',
                        value: Text('${report.rows.length}'),
                      ),
                      DetailRow(
                        label: 'Total received',
                        emphasised: true,
                        value: MoneyBagText(report.totalReceived),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _busy ? null : () => _generate(report),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Generate statement PDF'),
              ),
              const SizedBox(height: 10),
              Text(
                'Shows every payment received in the period, plus what is '
                'still outstanding today.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _generate(IncomeReport report) async {
    setState(() => _busy = true);
    try {
      final List<ClientSummary> summaries =
          await ref.read(clientSummariesProvider.future);
      final MoneyBag outstanding = summaries
              .where((ClientSummary s) => s.client.id == widget.client.id)
              .firstOrNull
              ?.outstanding ??
          MoneyBag.empty();

      final String businessName = await ref
              .read(ingestRepositoryProvider)
              .getSetting(SettingKeys.invoiceBusinessName) ??
          'Your business';

      final Uint8List bytes = await ref.read(invoicePdfProvider).buildStatement(
            businessName: businessName,
            clientName: widget.client.name,
            report: report,
            outstanding: outstanding,
          );

      if (!mounted) return;
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'statement-${widget.client.name}-${formatIsoDate(report.from)}.pdf',
      );
    } catch (error) {
      if (!mounted) return;
      showSnack(context, 'Could not generate: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
