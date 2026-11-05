import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/formatting.dart';
import '../../domain/calendar.dart';
import '../../domain/entities/payment_source.dart';
import '../../domain/export/income_report.dart';
import '../../domain/repositories/ingest_repository.dart';
import '../providers/app_providers.dart';
import '../providers/ledger_providers.dart';
import '../widgets/common.dart';
import 'backup_screen.dart';
import 'data_sources_screen.dart';

/// Settings: commission rates, business details, and the tax export.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PaymentSource>> sources =
        ref.watch(paymentSourcesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          const SectionHeader('APPEARANCE'),
          const _AppearanceCard(),
          const SectionHeader('DATA SOURCES'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_sync_outlined),
              title: const Text('Connected sources'),
              subtitle: const Text(
                'Statement upload, platform email, app notifications',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const DataSourcesScreen(),
                ),
              ),
            ),
          ),
          const SectionHeader('BACKUP & SYNC'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.backup_outlined),
              title: const Text('Backup & sync'),
              subtitle: const Text(
                'Encrypted copy in your Google Drive, to restore on another '
                'device',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const BackupScreen(),
                ),
              ),
            ),
          ),
          const SectionHeader('COMMISSION & TDS RATES'),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: AsyncView<List<PaymentSource>>(
                value: sources,
                builder: (BuildContext context, List<PaymentSource> data) {
                  return Column(
                    children: <Widget>[
                      for (final PaymentSource source in data)
                        ListTile(
                          title: Text(source.displayName),
                          subtitle: Text(
                            '${formatRate(source.commissionRateBps)} commission'
                            ' · ${formatRate(source.defaultTdsRateBps)} TDS',
                          ),
                          trailing: const Icon(Icons.edit_outlined, size: 18),
                          onTap: () => _editSource(context, ref, source),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
            child: Text(
              'Changing a rate affects new milestones only. Existing ones keep '
              'the rate they were created with, so past work still reconciles '
              'with what you were actually paid.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SectionHeader('YOUR DETAILS'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Business details'),
              subtitle: const Text('Shown on invoices and in reminders'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      const BusinessDetailsScreen(),
                ),
              ),
            ),
          ),
          const SectionHeader('EXPORT'),
          const _ExportCard(),
        ],
      ),
    );
  }

  Future<void> _editSource(
    BuildContext context,
    WidgetRef ref,
    PaymentSource source,
  ) async {
    final TextEditingController commission = TextEditingController(
      text: (source.commissionRateBps / 100).toString(),
    );
    final TextEditingController tds = TextEditingController(
      text: (source.defaultTdsRateBps / 100).toString(),
    );

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(source.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: commission,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Commission',
                suffixText: '%',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: tds,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Default TDS',
                suffixText: '%',
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved != true) return;

    final double? commissionPercent = double.tryParse(commission.text.trim());
    final double? tdsPercent = double.tryParse(tds.text.trim());
    if (commissionPercent == null || tdsPercent == null) {
      if (!context.mounted) return;
      showSnack(context, 'Enter rates as numbers, e.g. 20 or 12.5');
      return;
    }

    await ref.read(ledgerRepositoryProvider).updateSource(
          source.copyWith(
            commissionRateBps: (commissionPercent * 100).round(),
            defaultTdsRateBps: (tdsPercent * 100).round(),
          ),
        );
    if (!context.mounted) return;
    showSnack(context, '${source.displayName} updated');
  }
}

/// Light / Dark / System background selector.
///
/// "System" is the default and follows the phone's own light/dark setting; the
/// other two pin the app regardless of the phone. The choice is persisted, so
/// it survives a restart, and the whole app repaints the moment it changes
/// because [PayTrailApp] watches the same setting.
class _AppearanceCard extends ConsumerWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode mode = ref.watch(themeModeProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.brightness_6_outlined, size: 20),
                const SizedBox(width: 12),
                Text('Theme', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                // Labels only, no leading or selected icon: in three equal
                // thirds, "System" plus any icon is too wide and wraps. The
                // filled background already marks the selected segment.
                showSelectedIcon: false,
                segments: const <ButtonSegment<ThemeMode>>[
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    label: Text('System'),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    label: Text('Light'),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                  ),
                ],
                selected: <ThemeMode>{mode},
                onSelectionChanged: (Set<ThemeMode> selection) =>
                    setThemeMode(ref, selection.first),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The details printed on invoices and signed into reminders.
class BusinessDetailsScreen extends ConsumerStatefulWidget {
  const BusinessDetailsScreen({super.key});

  @override
  ConsumerState<BusinessDetailsScreen> createState() =>
      _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends ConsumerState<BusinessDetailsScreen> {
  final Map<String, TextEditingController> _fields =
      <String, TextEditingController>{};
  bool _loaded = false;

  static const Map<String, String> _labels = <String, String>{
    SettingKeys.invoiceBusinessName: 'Your name or business name',
    SettingKeys.invoiceEmail: 'Email',
    SettingKeys.invoicePhone: 'Phone',
    SettingKeys.invoiceAddress: 'Address',
    SettingKeys.invoiceTaxId: 'GSTIN / PAN',
    SettingKeys.invoiceNumberPrefix: 'Invoice number prefix',
    SettingKeys.invoiceNotes: 'Default invoice notes',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final IngestRepository repo = ref.read(ingestRepositoryProvider);
    for (final String key in _labels.keys) {
      _fields[key] = TextEditingController(text: await repo.getSetting(key) ?? '');
    }
    if (!mounted) return;
    setState(() => _loaded = true);
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final IngestRepository repo = ref.read(ingestRepositoryProvider);
    for (final MapEntry<String, TextEditingController> entry
        in _fields.entries) {
      final String value = entry.value.text.trim();
      if (value.isEmpty) {
        await repo.clearSetting(entry.key);
      } else {
        await repo.setSetting(entry.key, value);
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    showSnack(context, 'Details saved');
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Business details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: <Widget>[
          for (final MapEntry<String, String> entry in _labels.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TextField(
                controller: _fields[entry.key],
                maxLines: entry.key == SettingKeys.invoiceAddress ||
                        entry.key == SettingKeys.invoiceNotes
                    ? 3
                    : 1,
                decoration: InputDecoration(
                  labelText: entry.value,
                  alignLabelWithHint: true,
                  helperText: entry.key == SettingKeys.invoiceNumberPrefix
                      ? 'Invoices are numbered PREFIX-YEAR-0001'
                      : null,
                ),
              ),
            ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _ExportCard extends ConsumerStatefulWidget {
  const _ExportCard();

  @override
  ConsumerState<_ExportCard> createState() => _ExportCardState();
}

class _ExportCardState extends ConsumerState<_ExportCard> {
  bool _busy = false;
  DateTimeRange? _range;

  DateTimeRange get _effectiveRange =>
      _range ?? _currentFinancialYear(today());

  /// The Indian financial year containing [reference]: 1 April to 31 March.
  ///
  /// Defaulted to because that, not the calendar year, is the period an Indian
  /// freelancer files against.
  static DateTimeRange _currentFinancialYear(DateTime reference) {
    final int startYear = reference.month >= 4 ? reference.year : reference.year - 1;
    return DateTimeRange(
      start: DateTime(startYear, 4),
      end: DateTime(startYear + 1, 3, 31),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<IncomeRow>> rows = ref.watch(incomeRowsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Income CSV for tax filing',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'One row per payment received, with the client, project, source '
              'and reference. Amounts are plain numbers in their own column so '
              'a spreadsheet can sum them.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickRange,
              icon: const Icon(Icons.date_range_outlined, size: 18),
              label: Text(
                '${formatDate(_effectiveRange.start)} – '
                '${formatDate(_effectiveRange.end)}',
              ),
            ),
            const SizedBox(height: 10),
            AsyncView<List<IncomeRow>>(
              value: rows,
              loading: const LinearProgressIndicator(),
              builder: (BuildContext context, List<IncomeRow> data) {
                final IncomeReport report = IncomeReport.build(
                  rows: data,
                  from: _effectiveRange.start,
                  to: _effectiveRange.end,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      report.isEmpty
                          ? 'No payments received in this period.'
                          : '${report.rows.length} payments · '
                              '${formatMoneyBag(report.totalReceived)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed:
                          _busy || report.isEmpty ? null : () => _export(report),
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: const Text('Export CSV'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(today().year - 10),
      lastDate: DateTime(today().year + 1, 12, 31),
      initialDateRange: _effectiveRange,
    );
    if (picked != null) setState(() => _range = picked);
  }

  Future<void> _export(IncomeReport report) async {
    setState(() => _busy = true);
    try {
      final String csv = ref.read(csvExporterProvider).buildIncomeCsv(report);

      // Written to the app's own cache and shared from there. The sandbox
      // blocks a direct write to Downloads without a storage permission this
      // app has no other reason to hold.
      final Directory dir = await getTemporaryDirectory();
      final String name =
          'paytrail-income-${formatIsoDate(report.from)}-to-${formatIsoDate(report.to)}.csv';
      final File file = File(p.join(dir.path, name));
      await file.writeAsString(csv);

      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[XFile(file.path, mimeType: 'text/csv')],
          subject: 'PayTrail income export',
        ),
      );
    } catch (error) {
      if (!mounted) return;
      showSnack(context, 'Could not export: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
