import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/formatting.dart';
import '../../data/ingest/gmail_client.dart';
import '../../domain/reminders/reminder_rules.dart';
import '../../domain/repositories/ingest_repository.dart';
import '../providers/app_providers.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// The reminder queue: drafts to review, edit and send.
///
/// Nothing on this screen sends anything by itself. Each draft opens in the
/// user's own mail app, from their own address — a chasing email that arrives
/// from a third-party app is a worse email, and a chasing email the user did
/// not read before it went is a liability.
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ReminderDraft>> queue =
        ref.watch(reminderQueueProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Sent history',
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const _ReminderLogScreen(),
              ),
            ),
          ),
        ],
      ),
      body: AsyncView<List<ReminderDraft>>(
        value: queue,
        builder: (BuildContext context, List<ReminderDraft> drafts) {
          if (drafts.isEmpty) {
            return const EmptyState(
              icon: Icons.mark_email_read_outlined,
              title: 'Nothing to chase',
              message:
                  'Reminders appear once an invoiced milestone is 7 days past '
                  'due, and escalate at 30 and 60 days.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            itemCount: drafts.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) return _QueueHeader(count: drafts.length);
              return _ReminderCard(draft: drafts[index - 1]);
            },
          );
        },
      ),
    );
  }
}

class _QueueHeader extends StatelessWidget {
  const _QueueHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$count ${count == 1 ? 'reminder' : 'reminders'} ready. Review each one '
        'before it goes — they send from your own mail app.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ReminderCard extends ConsumerWidget {
  const _ReminderCard({required this.draft});

  final ReminderDraft draft;

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
                      Text(draft.client.name,
                          style: theme.textTheme.titleMedium),
                      Text(
                        '${draft.context.project.name} · '
                        '${draft.milestone.title}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    MoneyText(draft.amount),
                    const SizedBox(height: 4),
                    _ToneChip(tone: draft.tone, days: draft.daysOverdue),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              draft.subject,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!draft.canSend) ...<Widget>[
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.info_outline,
                    size: 15,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'No email address on file for this client.',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (draft.previouslySentAt != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                'Last ${draft.tone.label.toLowerCase()} sent '
                '${formatDate(draft.previouslySentAt!)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          ReminderComposeScreen(draft: draft),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Review & send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ToneChip extends StatelessWidget {
  const _ToneChip({required this.tone, required this.days});

  final ReminderTone tone;
  final int days;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final StatusColors status = context.statusColors;
    final (Color background, Color foreground) = switch (tone) {
      ReminderTone.nudge => (status.partialContainer, status.onPartialContainer),
      ReminderTone.firm => (status.overdueContainer, status.onOverdueContainer),
      ReminderTone.formal => (
          theme.colorScheme.errorContainer,
          theme.colorScheme.onErrorContainer,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${tone.label} · ${days}d',
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Edit a draft and hand it to the mail app.
class ReminderComposeScreen extends ConsumerStatefulWidget {
  const ReminderComposeScreen({required this.draft, super.key});

  final ReminderDraft draft;

  @override
  ConsumerState<ReminderComposeScreen> createState() =>
      _ReminderComposeScreenState();
}

class _ReminderComposeScreenState extends ConsumerState<ReminderComposeScreen> {
  late final TextEditingController _to;
  late final TextEditingController _subject;
  late final TextEditingController _body;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _to = TextEditingController(text: widget.draft.recipient ?? '');
    _subject = TextEditingController(text: widget.draft.subject);
    _body = TextEditingController(text: widget.draft.body);
  }

  @override
  void dispose() {
    _to.dispose();
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // When a Gmail account is connected, the reminder is sent directly from it;
    // otherwise it opens the user's mail app. Watched so the button reflects the
    // connection the moment it changes.
    final String? gmailAccount =
        ref.watch(settingProvider(SettingKeys.gmailAccount)).value;
    final bool gmailConnected =
        gmailAccount != null && gmailAccount.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(widget.draft.tone.label)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: <Widget>[
          Card(
            color: theme.colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.draft.client.name,
                      style: theme.textTheme.titleSmall),
                  Text(
                    '${formatMoney(widget.draft.amount)} · '
                    '${widget.draft.daysOverdue} days overdue · due '
                    '${formatDate(widget.draft.milestone.dueDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _to,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'To'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _subject,
            decoration: const InputDecoration(labelText: 'Subject'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _body,
            maxLines: 16,
            decoration: const InputDecoration(
              labelText: 'Message',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _sending ? null : _send,
            icon: _sending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_outlined),
            label: Text(gmailConnected ? 'Send from Gmail' : 'Open in mail app'),
          ),
          const SizedBox(height: 8),
          Text(
            gmailConnected
                ? 'Sends from your connected Gmail ($gmailAccount) and files it '
                    'in your Sent folder. Logged as sent, so the same reminder '
                    'is not offered again for a week.'
                : 'This opens your mail app with the message ready. It is logged '
                    'as sent once you come back, so the same reminder is not '
                    'offered again for a week.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final String to = _to.text.trim();
    if (to.isEmpty) {
      showSnack(context, 'Add an email address first');
      return;
    }

    setState(() => _sending = true);

    // Prefer sending directly from the connected Gmail so the chase goes out
    // from the user's own address and lands in their Sent folder. If Gmail is
    // not connected, or the send permission was not granted, or the API call
    // fails, fall back to opening the user's mail app — the reminder is never
    // lost to a transient failure.
    final String? account = await ref
        .read(ingestRepositoryProvider)
        .getSetting(SettingKeys.gmailAccount);

    if (account != null && account.isNotEmpty) {
      try {
        final GmailClient client = ref.read(gmailClientProvider);
        await client.initialize(serverClientId: kGmailServerClientId);
        await client.sendEmail(
          to: to,
          subject: _subject.text,
          body: _body.text,
        );
        await _logSent(to);
        if (!mounted) return;
        Navigator.of(context).pop();
        showSnack(context, 'Sent from $account');
        return;
      } on GmailSendException catch (error) {
        // Send was never granted (e.g. an account connected before sending was
        // added): tell the user how to enable it, then open the mail app.
        if (mounted) showSnack(context, error.message);
      } catch (_) {
        if (mounted) {
          showSnack(context, 'Could not send via Gmail — opening your mail app.');
        }
      }
    }

    await _openInMailApp(to);
  }

  /// Opens the user's mail app with the reminder prefilled (the fallback path).
  Future<void> _openInMailApp(String to) async {
    // Percent-encode each field by hand (space → %20, newline → %0A, '&' → %26).
    // Uri.queryParameters uses form-encoding, which turns spaces into '+' — and
    // many mail apps paste that '+' into the body literally instead of decoding
    // it back to a space. encodeComponent avoids that.
    final Uri uri = Uri.parse(
      'mailto:${Uri.encodeComponent(to)}'
      '?subject=${Uri.encodeComponent(_subject.text)}'
      '&body=${Uri.encodeComponent(_body.text)}',
    );

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) throw StateError('No mail app is available.');

      // Logged after handing off, not before: the log means "this went out",
      // and the suppression rules depend on that being true.
      await _logSent(to);

      if (!mounted) return;
      Navigator.of(context).pop();
      showSnack(context, 'Reminder logged as sent');
    } catch (error) {
      if (!mounted) return;
      setState(() => _sending = false);
      showSnack(context, 'Could not open a mail app: $error');
    }
  }

  Future<void> _logSent(String to) {
    return ref.read(reminderRepositoryProvider).recordSent(
          milestoneId: widget.draft.milestone.id,
          clientId: widget.draft.client.id,
          tone: widget.draft.tone,
          subject: _subject.text,
          body: _body.text,
          recipient: to,
        );
  }
}

class _ReminderLogScreen extends ConsumerWidget {
  const _ReminderLogScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ReminderLogEntry>> log =
        ref.watch(reminderLogProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders sent')),
      body: AsyncView<List<ReminderLogEntry>>(
        value: log,
        builder: (BuildContext context, List<ReminderLogEntry> entries) {
          if (entries.isEmpty) {
            return const EmptyState(
              icon: Icons.history,
              title: 'No reminders sent yet',
              message: 'Every reminder you send is recorded here and on the '
                  'client, so you can show exactly when you chased.',
            );
          }
          return ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int index) {
              final ReminderLogEntry entry = entries[index];
              return ListTile(
                title: Text(
                  entry.subject,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${entry.tone.label} · ${formatDate(entry.sentAt)}'
                  '${entry.recipient == null ? '' : ' · ${entry.recipient}'}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
