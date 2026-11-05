import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../domain/ingest/payment_event.dart';
import '../../domain/ingest/payment_source_adapter.dart';
import '../../domain/repositories/ingest_repository.dart';
import '../providers/app_providers.dart';
import '../widgets/common.dart';

/// Where the user turns each ingestion path on, and sees exactly what it does.
///
/// Every source is off until switched on here, and each one states its scope in
/// plain words before it is enabled. That is the whole consent model: no
/// background capability exists that the user has not read a sentence about and
/// agreed to.
class DataSourcesScreen extends ConsumerStatefulWidget {
  const DataSourcesScreen({super.key});

  @override
  ConsumerState<DataSourcesScreen> createState() => _DataSourcesScreenState();
}

class _DataSourcesScreenState extends ConsumerState<DataSourcesScreen> {
  bool _busy = false;
  String? _status;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final PaymentSourceRegistry registry = ref.watch(sourceRegistryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Data sources')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Text(
            'PayTrail reads only what you switch on here, and only from the '
            'platforms listed. Everything is processed on this device and '
            'stored in the encrypted ledger.',
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
          const SectionHeader('STATEMENT UPLOAD'),
          _SourceCard(
            icon: Icons.upload_file_outlined,
            title: 'Upload a statement',
            scope: 'You download a CSV from Fiverr or Upwork and choose it '
                'here. Nothing is read until you pick a file, and the file is '
                'parsed on this device — it is never uploaded anywhere.',
            recommended: true,
            recommendationNote:
                'The most reliable path: deterministic, and it gives complete '
                'history rather than only what arrives from now on.',
            child: Row(
              children: <Widget>[
                for (final PaymentSourceAdapter adapter in registry.adapters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: OutlinedButton.icon(
                      onPressed:
                          _busy ? null : () => _uploadStatement(adapter),
                      icon: const Icon(Icons.description_outlined, size: 18),
                      label: Text(adapter.displayName),
                    ),
                  ),
              ],
            ),
          ),
          const SectionHeader('PLATFORM EMAIL'),
          _GmailCard(
            onStatus: (String message) => setState(() => _status = message),
            registry: registry,
          ),
          const SectionHeader('CUSTOM EMAIL SENDERS'),
          const _CustomSendersCard(),
          const SectionHeader('APP NOTIFICATIONS'),
          const _NotificationCard(),
          const SectionHeader('WHAT IS STORED'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _policyLine(
                    context,
                    Icons.lock_outline,
                    'The ledger file is encrypted with SQLCipher. The key is '
                    'generated on this device and held in the Android '
                    'Keystore.',
                  ),
                  _policyLine(
                    context,
                    Icons.cloud_off_outlined,
                    'Nothing is sent to a PayTrail server. There is no '
                    'PayTrail server.',
                  ),
                  _policyLine(
                    context,
                    Icons.visibility_outlined,
                    'Every captured payment waits in the review queue until '
                    'you confirm it. Nothing is added to your books '
                    'automatically.',
                  ),
                  _policyLine(
                    context,
                    Icons.delete_outline,
                    'Turning a source off stops further capture. Clearing the '
                    'app data deletes the ledger and its key permanently.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _policyLine(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadStatement(PaymentSourceAdapter adapter) async {
    setState(() {
      _busy = true;
      _status = null;
    });

    try {
      final PlatformFile? file = await FilePicker.pickFile(
        dialogTitle: 'Choose your ${adapter.displayName} statement',
        type: FileType.custom,
        allowedExtensions: <String>['csv', 'txt'],
      );
      if (file == null) {
        setState(() => _busy = false);
        return;
      }

      // Decoded leniently: marketplace exports occasionally carry a stray byte
      // from a client's name, and losing one character is far better than
      // refusing the whole statement.
      final String content =
          utf8.decode(await file.readAsBytes(), allowMalformed: true);

      final IngestResult parsed = adapter.parseStatement(content);
      final IntakeSummary summary = await ref
          .read(ingestRepositoryProvider)
          .stage(parsed.events, issues: parsed.issues);

      if (!mounted) return;
      await ref
          .read(ingestRepositoryProvider)
          .setSetting(SettingKeys.consentStatements, 'true');

      setState(() {
        _busy = false;
        _status = _describeIntake(adapter.displayName, summary, parsed);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _status = 'Could not read that file: $error';
      });
    }
  }

  static String _describeIntake(
    String platform,
    IntakeSummary summary,
    IngestResult parsed,
  ) {
    final StringBuffer message = StringBuffer();
    if (summary.staged > 0) {
      message.write(
        '${summary.staged} new ${summary.staged == 1 ? 'payment' : 'payments'} '
        'from $platform are waiting in the review queue.',
      );
    } else {
      message.write('No new payments found in that $platform file.');
    }
    if (summary.duplicatesSkipped > 0) {
      message.write(
        ' ${summary.duplicatesSkipped} were already recorded and were skipped.',
      );
    }
    if (parsed.issues.isNotEmpty) {
      message.write('\n\nSkipped rows:');
      for (final IngestIssue issue in parsed.issues.take(5)) {
        message.write('\n• $issue');
      }
      if (parsed.issues.length > 5) {
        message.write('\n• …and ${parsed.issues.length - 5} more');
      }
    }
    return message.toString();
  }
}

/// A source, its scope, and its control.
class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.icon,
    required this.title,
    required this.scope,
    required this.child,
    this.recommended = false,
    this.recommendationNote,
    this.trailing,
  });

  final IconData icon;
  final String title;

  /// Exactly what this source reads, in words the user can act on.
  final String scope;

  final Widget child;
  final bool recommended;
  final String? recommendationNote;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 8),
            Text(
              scope,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (recommended && recommendationNote != null) ...<Widget>[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.star_outline,
                    size: 15,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      recommendationNote!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _GmailCard extends ConsumerStatefulWidget {
  const _GmailCard({required this.onStatus, required this.registry});

  final ValueChanged<String> onStatus;
  final PaymentSourceRegistry registry;

  @override
  ConsumerState<_GmailCard> createState() => _GmailCardState();
}

class _GmailCardState extends ConsumerState<_GmailCard> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? account =
        ref.watch(settingProvider(SettingKeys.gmailAccount)).value;
    final String? lastSynced =
        ref.watch(settingProvider(SettingKeys.gmailLastSyncedAt)).value;
    final List<String> domains = widget.registry.allEmailDomains.toList()
      ..sort();

    return _SourceCard(
      icon: Icons.mark_email_read_outlined,
      title: 'Read platform email',
      scope: 'Read-only access to Gmail, filtered in the request itself to '
          'mail from ${domains.join(', ')} plus any custom senders you add '
          'below. PayTrail cannot send, delete or change any message — the '
          'permission it asks for does not allow it. Mail from anyone else is '
          'never downloaded.',
      trailing: account == null
          ? null
          : Icon(Icons.check_circle, color: theme.colorScheme.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (account != null) ...<Widget>[
            Text(
              'Connected as $account',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (lastSynced != null)
              Text(
                'Last checked ${formatDate(DateTime.parse(lastSynced))}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 10),
          ],
          Row(
            children: <Widget>[
              if (account == null)
                FilledButton.tonalIcon(
                  onPressed: _busy ? null : _connect,
                  icon: const Icon(Icons.link, size: 18),
                  label: const Text('Connect Gmail'),
                )
              else ...<Widget>[
                FilledButton.tonalIcon(
                  onPressed: _busy ? null : _sync,
                  icon: const Icon(Icons.sync, size: 18),
                  label: const Text('Check now'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _busy ? null : _disconnect,
                  child: const Text('Disconnect'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _connect() async {
    setState(() => _busy = true);
    try {
      // google_sign_in needs the Web client id as serverClientId on Android;
      // app identity still comes from the Android client's package + SHA-1.
      await ref
          .read(gmailClientProvider)
          .initialize(serverClientId: kGmailServerClientId);
      final String? email = await ref.read(gmailClientProvider).connect();
      if (email == null) throw StateError('Sign-in was cancelled.');

      final IngestRepository repo = ref.read(ingestRepositoryProvider);
      await repo.setSetting(SettingKeys.gmailAccount, email);
      await repo.setSetting(SettingKeys.consentEmail, 'true');
      if (!mounted) return;
      widget.onStatus('Connected $email. Tap "Check now" to scan for payments.');
    } catch (error) {
      if (!mounted) return;
      widget.onStatus(
        'Could not connect Gmail: $error\n\n'
        'This needs a Google Cloud OAuth client for the app\'s package name '
        'and signing certificate. See README.md.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sync() async {
    setState(() => _busy = true);
    try {
      final IngestRepository repo = ref.read(ingestRepositoryProvider);
      final String? lastSynced =
          await repo.getSetting(SettingKeys.gmailLastSyncedAt);

      final Set<String> customSenders = parseSenderList(
        await repo.getSetting(SettingKeys.customEmailSenders),
      ).toSet();
      final IngestResult result =
          await ref.read(gmailClientProvider).fetchPayments(
                since: lastSynced == null ? null : DateTime.tryParse(lastSynced),
                customSenders: customSenders,
              );
      final IntakeSummary summary =
          await repo.stage(result.events, issues: result.issues);
      await repo.setSetting(
        SettingKeys.gmailLastSyncedAt,
        DateTime.now().toIso8601String(),
      );

      if (!mounted) return;
      widget.onStatus(
        summary.staged > 0
            ? '${summary.staged} new payment email(s) queued for review.'
            : 'No new payment emails found.'
                '${summary.duplicatesSkipped > 0 ? ' ${summary.duplicatesSkipped} already recorded.' : ''}',
      );
    } catch (error) {
      if (!mounted) return;
      widget.onStatus('Could not check Gmail: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disconnect() async {
    setState(() => _busy = true);
    try {
      await ref.read(gmailClientProvider).disconnect();
      final IngestRepository repo = ref.read(ingestRepositoryProvider);
      await repo.clearSetting(SettingKeys.gmailAccount);
      await repo.clearSetting(SettingKeys.gmailLastSyncedAt);
      await repo.setSetting(SettingKeys.consentEmail, 'false');
      if (!mounted) return;
      widget.onStatus('Gmail disconnected.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _NotificationCard extends ConsumerStatefulWidget {
  const _NotificationCard();

  @override
  ConsumerState<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends ConsumerState<_NotificationCard> {
  bool? _granted;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final bool granted =
        await ref.read(notificationCaptureProvider).isPermissionGranted();
    if (!mounted) return;
    setState(() => _granted = granted);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final PaymentSourceRegistry registry = ref.watch(sourceRegistryProvider);
    final List<String> packages =
        registry.allNotificationPackages.toList()..sort();

    return _SourceCard(
      icon: Icons.notifications_active_outlined,
      title: 'Capture app notifications',
      scope: 'Android shows PayTrail every notification on the device. The '
          'listener discards all of them except those posted by '
          '${packages.join(' and ')}, before reading any content. Nothing from '
          'your messages, mail or banking apps is read or stored.',
      trailing: _granted == true
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _granted == true
                ? 'Notification access is on. New payouts appear in the review '
                    'queue as they arrive.'
                : 'Android only lets you grant this in Settings. Find PayTrail '
                    'in the list and switch it on.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              FilledButton.tonalIcon(
                onPressed: () async {
                  final NotificationCaptureActions actions =
                      NotificationCaptureActions(ref);
                  await actions.enable();
                  if (!context.mounted) return;
                  await _refresh();
                },
                icon: const Icon(Icons.settings_outlined, size: 18),
                label: Text(
                  _granted == true ? 'Open settings' : 'Grant access',
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _refresh,
                child: const Text('Re-check'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small helper so the button above reads as one action.
class NotificationCaptureActions {
  const NotificationCaptureActions(this.ref);

  final WidgetRef ref;

  /// Records consent, pushes the allowlist, and opens the system page.
  ///
  /// The allowlist is pushed before the user grants access so the service is
  /// correctly configured the instant Android binds it.
  Future<void> enable() async {
    await ref
        .read(ingestRepositoryProvider)
        .setSetting(SettingKeys.consentNotifications, 'true');
    await ref.read(notificationCaptureProvider).syncAllowedPackages();
    await ref.read(notificationCaptureProvider).openPermissionSettings();
  }
}

/// Splits the stored custom-sender setting into a clean, de-duplicated list.
///
/// Stored as newline-separated text; commas are accepted too so a pasted list
/// still works. Lower-cased and trimmed here so matching and display agree.
List<String> parseSenderList(String? raw) {
  if (raw == null || raw.trim().isEmpty) return <String>[];
  final List<String> seen = <String>[];
  for (final String part in raw.split(RegExp(r'[\n,]'))) {
    final String value = part.trim().toLowerCase();
    if (value.isNotEmpty && !seen.contains(value)) seen.add(value);
  }
  return seen;
}

/// A bare domain (`client.com`) or a full address (`pay@client.com`).
bool _isValidSender(String value) {
  if (value.isEmpty || value.length > 254) return false;
  final RegExp domain = RegExp(r'^[a-z0-9.-]+\.[a-z]{2,}$');
  final RegExp email = RegExp(r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$');
  return domain.hasMatch(value) || email.hasMatch(value);
}

/// Lets the user widen the email allowlist to their own clients and providers.
///
/// Senders added here are folded into the Gmail query and read the same
/// read-only way as the built-in platforms; because there is no format to rely
/// on, their mail is parsed by a generic amount/date read and — like every
/// other source — lands in the review queue for confirmation, never the ledger.
class _CustomSendersCard extends ConsumerStatefulWidget {
  const _CustomSendersCard();

  @override
  ConsumerState<_CustomSendersCard> createState() => _CustomSendersCardState();
}

class _CustomSendersCardState extends ConsumerState<_CustomSendersCard> {
  final TextEditingController _controller = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<String> senders = parseSenderList(
      ref.watch(settingProvider(SettingKeys.customEmailSenders)).value,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Read email from your own senders',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Add a direct client\'s address or a payment provider domain — '
              'for example razorpay.com or accounts@client.com. These are read '
              'the same read-only way as the platforms, and every payment found '
              'still waits in the review queue for you to confirm.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (senders.isEmpty)
              Text(
                'No custom senders yet.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              for (final String sender in senders)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.alternate_email,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(sender,
                            style: theme.textTheme.bodyMedium),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Remove',
                        icon: const Icon(Icons.close, size: 18),
                        onPressed:
                            _busy ? null : () => _remove(senders, sender),
                      ),
                    ],
                  ),
                ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'domain.com or name@domain.com',
                      errorText: _error,
                    ),
                    onSubmitted: (_) => _add(senders),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _busy ? null : () => _add(senders),
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _add(List<String> current) async {
    final String value = _controller.text.trim().toLowerCase();
    if (!_isValidSender(value)) {
      setState(() => _error = 'Enter a domain or an email address.');
      return;
    }
    if (current.contains(value)) {
      setState(() => _error = 'Already added.');
      return;
    }
    setState(() {
      _error = null;
      _busy = true;
    });
    await _persist(<String>[...current, value]);
    if (!mounted) return;
    _controller.clear();
    setState(() => _busy = false);
  }

  Future<void> _remove(List<String> current, String sender) async {
    setState(() => _busy = true);
    await _persist(current.where((String s) => s != sender).toList());
    if (!mounted) return;
    setState(() => _busy = false);
  }

  Future<void> _persist(List<String> senders) => ref
      .read(ingestRepositoryProvider)
      .setSetting(SettingKeys.customEmailSenders, senders.join('\n'));
}
