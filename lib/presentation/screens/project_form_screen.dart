import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../domain/entities/payment_source.dart';
import '../../domain/entities/project.dart';
import '../../domain/money.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../providers/ledger_providers.dart';
import '../widgets/common.dart';

/// Add or edit a project under one client.
class ProjectFormScreen extends ConsumerStatefulWidget {
  const ProjectFormScreen({required this.clientId, super.key, this.existing});

  final String clientId;

  /// Null when adding.
  final Project? existing;

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _externalRef;
  late String _sourceId;
  late String _currency;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final Project? existing = widget.existing;
    _name = TextEditingController(text: existing?.name ?? '');
    _description = TextEditingController(text: existing?.description ?? '');
    _externalRef = TextEditingController(text: existing?.externalRef ?? '');
    _sourceId = existing?.defaultSourceId ?? SourceIds.direct;
    _currency = existing?.defaultCurrency ?? kDefaultCurrency;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _externalRef.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final LedgerRepository repo = ref.read(ledgerRepositoryProvider);
    final ProjectDraft draft = ProjectDraft(
      clientId: widget.clientId,
      name: _name.text,
      defaultSourceId: _sourceId,
      defaultCurrency: _currency,
      description: _description.text,
      externalRef: _externalRef.text,
    );

    try {
      if (_isEditing) {
        await repo.updateProject(widget.existing!.id, draft);
      } else {
        await repo.createProject(draft);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      showSnack(context, _isEditing ? 'Project updated' : 'Project added');
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
      appBar: AppBar(title: Text(_isEditing ? 'Edit project' : 'New project')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: <Widget>[
            TextFormField(
              controller: _name,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Project name *',
                hintText: 'Website revamp, Monthly retainer…',
              ),
              validator: (String? value) =>
                  (value == null || value.trim().isEmpty)
                      ? 'A project name is required'
                      : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
              ),
            ),
            const SectionHeader('DEFAULTS FOR NEW MILESTONES'),
            Text(
              'Each milestone stores its own source and currency. These only '
              'prefill the form, so changing them later never alters work you '
              'have already recorded.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            AsyncView<List<PaymentSource>>(
              value: sources,
              loading: const LinearProgressIndicator(),
              builder: (BuildContext context, List<PaymentSource> data) {
                // Guard against a source that was removed while this form was
                // open, which would otherwise assert inside DropdownButton.
                final bool known =
                    data.any((PaymentSource s) => s.id == _sourceId);
                return DropdownButtonFormField<String>(
                  initialValue: known ? _sourceId : null,
                  decoration: const InputDecoration(labelText: 'Source'),
                  items: <DropdownMenuItem<String>>[
                    for (final PaymentSource source in data)
                      DropdownMenuItem<String>(
                        value: source.id,
                        child: Text(
                          source.commissionRateBps == 0
                              ? source.displayName
                              : '${source.displayName} · '
                                  '${formatRate(source.commissionRateBps)} commission',
                        ),
                      ),
                  ],
                  onChanged: (String? value) {
                    if (value != null) setState(() => _sourceId = value);
                  },
                  validator: (String? value) =>
                      value == null ? 'Pick a source' : null,
                );
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _externalRef,
              decoration: const InputDecoration(
                labelText: 'Platform reference',
                hintText: 'Upwork contract id, Fiverr order id…',
                helperText:
                    'Used later to match imported payments to this project',
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
              label: Text(_isEditing ? 'Save changes' : 'Add project'),
            ),
          ],
        ),
      ),
    );
  }
}
