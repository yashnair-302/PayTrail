import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../data/backup/backup_crypto.dart';
import '../../domain/repositories/ingest_repository.dart';
import '../providers/app_providers.dart';
import '../widgets/common.dart';

/// Backup and cross-device sync, end-to-end encrypted against the user's Drive.
///
/// The whole account model is "sign in with Google": one account is the
/// identity, the same account on another device finds the same backup, and the
/// recovery passphrase — never stored, never sent — is the only thing that can
/// open it. There is no PayTrail login, and so nothing to reset.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final TextEditingController _passphrase = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  String? _status;

  @override
  void dispose() {
    _passphrase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? account =
        ref.watch(settingProvider(SettingKeys.backupAccount)).value;
    final String? lastAt =
        ref.watch(settingProvider(SettingKeys.backupLastAt)).value;
    final bool connected = account != null && account.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & sync')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Text(
            'PayTrail keeps an encrypted copy of your ledger in your own Google '
            'Drive. Sign in with the same account on another phone and restore '
            'it there — that is how your data moves between devices.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (_status != null) ...<Widget>[
            const SizedBox(height: 14),
            Card(
              color: theme.colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  _status!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ),
          ],
          const SectionHeader('GOOGLE ACCOUNT'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    connected
                        ? 'Backing up to $account'
                        : 'No account connected yet.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (connected && lastAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Last backup ${formatDate(DateTime.parse(lastAt))}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      if (!connected)
                        FilledButton.tonalIcon(
                          onPressed: _busy ? null : _connect,
                          icon: const Icon(Icons.link, size: 18),
                          label: const Text('Connect Google Drive'),
                        )
                      else
                        TextButton(
                          onPressed: _busy ? null : _disconnect,
                          child: const Text('Disconnect'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader('RECOVERY PASSPHRASE'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: _passphrase,
                    obscureText: _obscure,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      labelText: 'Passphrase',
                      helperText:
                          'At least ${BackupCrypto.minPassphraseLength} '
                          'characters',
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The same passphrase encrypts the backup and is the only '
                    'thing that can open it — not even Google can read your '
                    'ledger. Keep it safe: if you forget it, the backup cannot '
                    'be recovered.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _busy || !connected ? null : _backupNow,
            icon: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            label: const Text('Back up now'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _busy || !connected ? null : _restore,
            icon: const Icon(Icons.cloud_download_outlined),
            label: const Text('Restore on this device'),
          ),
          const SizedBox(height: 10),
          Text(
            'Restoring replaces everything currently in this device\'s ledger '
            'with the backup. Use it on a new phone, or to recover after a '
            'reinstall.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _connect() async {
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final String? email = await ref.read(backupServiceProvider).connect();
      if (email == null) throw StateError('Sign-in was cancelled.');
      await ref
          .read(ingestRepositoryProvider)
          .setSetting(SettingKeys.backupAccount, email);
      if (!mounted) return;
      setState(() => _status = 'Connected $email.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _status = 'Could not connect: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disconnect() async {
    setState(() => _busy = true);
    try {
      await ref.read(backupServiceProvider).disconnect();
      final IngestRepository repo = ref.read(ingestRepositoryProvider);
      await repo.clearSetting(SettingKeys.backupAccount);
      await repo.clearSetting(SettingKeys.backupLastAt);
      if (!mounted) return;
      setState(() => _status = 'Disconnected.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _backupNow() async {
    final String passphrase = _passphrase.text;
    if (passphrase.length < BackupCrypto.minPassphraseLength) {
      setState(() => _status =
          'Choose a passphrase of at least ${BackupCrypto.minPassphraseLength} '
          'characters first.');
      return;
    }
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      await ref.read(backupServiceProvider).backupNow(passphrase);
      await ref.read(ingestRepositoryProvider).setSetting(
            SettingKeys.backupLastAt,
            DateTime.now().toIso8601String(),
          );
      if (!mounted) return;
      setState(() => _status = 'Backup uploaded to your Drive.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _status = 'Backup failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final String passphrase = _passphrase.text;
    if (passphrase.isEmpty) {
      setState(() => _status = 'Enter the passphrase your backup was made with.');
      return;
    }

    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Replace this device\'s data?'),
            content: const Text(
              'Restoring overwrites everything currently in this ledger with '
              'the backup from your Drive. This cannot be undone.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Restore'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final bool restored =
          await ref.read(backupServiceProvider).restore(passphrase);
      if (!mounted) return;
      setState(() => _status = restored
          ? 'Ledger restored from your Drive backup.'
          : 'No backup was found for this account yet.');
    } on BackupPassphraseError catch (error) {
      if (!mounted) return;
      setState(() => _status = '$error');
    } catch (error) {
      if (!mounted) return;
      setState(() => _status = 'Restore failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
