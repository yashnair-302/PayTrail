import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/client.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../providers/ledger_providers.dart';
import '../widgets/common.dart';

/// Add or edit a client.
class ClientFormScreen extends ConsumerStatefulWidget {
  const ClientFormScreen({super.key, this.existing});

  /// Null when adding.
  final Client? existing;

  @override
  ConsumerState<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends ConsumerState<ClientFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _company;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _notes;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final Client? existing = widget.existing;
    _name = TextEditingController(text: existing?.name ?? '');
    _company = TextEditingController(text: existing?.company ?? '');
    _email = TextEditingController(text: existing?.email ?? '');
    _phone = TextEditingController(text: existing?.phone ?? '');
    _notes = TextEditingController(text: existing?.notes ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _company.dispose();
    _email.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final LedgerRepository repo = ref.read(ledgerRepositoryProvider);
    final ClientDraft draft = ClientDraft(
      name: _name.text,
      company: _company.text,
      email: _email.text,
      phone: _phone.text,
      notes: _notes.text,
    );

    try {
      if (_isEditing) {
        await repo.updateClient(widget.existing!.id, draft);
      } else {
        await repo.createClient(draft);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      showSnack(context, _isEditing ? 'Client updated' : 'Client added');
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showSnack(context, 'Could not save: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit client' : 'New client'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: <Widget>[
            TextFormField(
              controller: _name,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name *',
                hintText: 'Who you invoice',
              ),
              validator: (String? value) =>
                  (value == null || value.trim().isEmpty)
                      ? 'A name is required'
                      : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _company,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Company'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                helperText: 'Used to address payment reminders',
              ),
              validator: (String? value) {
                final String trimmed = (value ?? '').trim();
                if (trimmed.isEmpty) return null;
                // Deliberately loose: the only job here is to catch a typo
                // before a reminder bounces, not to police valid addresses.
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed)) {
                  return 'That does not look like an email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notes,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Payment terms, billing contact, anything useful',
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
              label: Text(_isEditing ? 'Save changes' : 'Add client'),
            ),
          ],
        ),
      ),
    );
  }
}
