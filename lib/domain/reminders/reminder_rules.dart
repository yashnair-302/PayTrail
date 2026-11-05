import '../entities/client.dart';
import '../entities/milestone.dart';
import '../money.dart';
import '../repositories/ledger_repository.dart';

/// The reminder engine: which milestones need chasing, and in what tone.
///
/// Pure functions over the open milestones and the log of what has already been
/// sent. Nothing here sends anything — it produces drafts. Sending is a
/// separate, explicit act by the user, because an app that emails a client
/// automatically will eventually email the wrong one.

/// How firmly to write, escalating with age.
enum ReminderTone {
  /// 7 days. A polite nudge; assume it was an oversight, because it usually is.
  nudge,

  /// 30 days. Direct, names the amount and the age, asks for a payment date.
  firm,

  /// 60 days. A formal notice that references the contract and states what
  /// happens next.
  formal;

  String get label => switch (this) {
        ReminderTone.nudge => 'Gentle nudge',
        ReminderTone.firm => 'Firm follow-up',
        ReminderTone.formal => 'Formal notice',
      };

  /// Days overdue at which this tone becomes appropriate.
  int get thresholdDays => switch (this) {
        ReminderTone.nudge => 7,
        ReminderTone.firm => 30,
        ReminderTone.formal => 60,
      };
}

/// A subject and body with `{{placeholder}}` slots.
class ReminderTemplate {
  const ReminderTemplate({
    required this.tone,
    required this.subject,
    required this.body,
  });

  final ReminderTone tone;
  final String subject;
  final String body;

  /// Substitutes [values] into both subject and body.
  ///
  /// An unknown placeholder is left intact rather than blanked: a visible
  /// `{{invoice}}` in the draft tells the user something is missing, whereas an
  /// empty gap ships a sentence with a hole in it.
  ({String subject, String body}) render(Map<String, String> values) {
    return (
      subject: _fill(subject, values),
      body: _fill(body, values),
    );
  }

  static String _fill(String template, Map<String, String> values) {
    return template.replaceAllMapped(
      RegExp(r'\{\{\s*(\w+)\s*\}\}'),
      (Match match) => values[match.group(1)] ?? match.group(0)!,
    );
  }
}

/// The wording shipped with the app. Users can edit these in Settings.
///
/// Written to be sendable as-is by someone who dislikes writing these emails —
/// which is most freelancers, and the reason invoices go unchased.
const List<ReminderTemplate> kDefaultTemplates = <ReminderTemplate>[
  ReminderTemplate(
    tone: ReminderTone.nudge,
    subject: 'Quick reminder: invoice {{invoice}} for {{project}}',
    body: '''
Hi {{client}},

Hope you are doing well. Just a quick note that {{amount}} for {{milestone}} was due on {{due_date}}, so it is now {{days}} days past due.

It has very likely just slipped through — could you let me know once it is on its way?

Thanks,
{{me}}''',
  ),
  ReminderTemplate(
    tone: ReminderTone.firm,
    subject: 'Overdue: {{amount}} for {{project}} ({{days}} days)',
    body: '''
Hi {{client}},

I am following up on invoice {{invoice}} for {{milestone}}. The amount of {{amount}} was due on {{due_date}} and is now {{days}} days overdue.

Could you confirm a payment date by return? If there is a problem with the invoice or anything is holding it up on your side, tell me and I will sort it out.

Thanks,
{{me}}''',
  ),
  ReminderTemplate(
    tone: ReminderTone.formal,
    subject: 'Formal notice: {{amount}} outstanding for {{days}} days',
    body: '''
Dear {{client}},

Despite previous reminders, invoice {{invoice}} for {{milestone}} remains unpaid. The amount of {{amount}} fell due on {{due_date}} and is now {{days}} days overdue.

Please arrange payment within 7 days of this notice. If payment or a written explanation is not received by then, I will have to pause any further work and pursue recovery of the amount.

I would much rather settle this directly. Please get in touch.

Regards,
{{me}}''',
  ),
];

/// A record that a reminder was sent.
class ReminderLogEntry {
  const ReminderLogEntry({
    required this.id,
    required this.milestoneId,
    required this.clientId,
    required this.tone,
    required this.subject,
    required this.sentAt,
    this.recipient,
    this.body,
  });

  final String id;
  final String milestoneId;
  final String clientId;
  final ReminderTone tone;
  final String subject;
  final String? body;
  final String? recipient;
  final DateTime sentAt;
}

/// A reminder ready for the user to review, edit and send.
class ReminderDraft {
  const ReminderDraft({
    required this.context,
    required this.tone,
    required this.subject,
    required this.body,
    required this.daysOverdue,
    this.recipient,
    this.previouslySentAt,
  });

  final MilestoneWithContext context;
  final ReminderTone tone;
  final String subject;
  final String body;
  final int daysOverdue;

  /// The client's email, when one is on file.
  ///
  /// Null means the draft can be prepared but not opened in a mail app; the
  /// screen prompts for an address rather than silently dropping the reminder.
  final String? recipient;

  /// When a reminder of this same tone last went out, if ever.
  final DateTime? previouslySentAt;

  Milestone get milestone => context.milestone;
  Client get client => context.client;
  Money get amount => milestone.outstanding;

  bool get canSend => recipient != null && recipient!.isNotEmpty;
}

/// How long to wait before offering the same tone again.
///
/// Without this, a milestone 40 days overdue would generate a fresh "firm"
/// draft every time the screen opened, and the queue would read as noise rather
/// than a to-do list.
const Duration kResendInterval = Duration(days: 7);

/// Builds the review queue.
///
/// For each overdue milestone the highest tone whose threshold has been passed
/// wins — a 70-day debt gets the formal notice, not three drafts. A milestone is
/// skipped when the same tone went out within [kResendInterval].
List<ReminderDraft> buildReminderQueue({
  required List<MilestoneWithContext> open,
  required List<ReminderLogEntry> log,
  required DateTime asOf,
  required String senderName,
  List<ReminderTemplate> templates = kDefaultTemplates,
  String Function(Money amount)? formatAmount,
  String Function(DateTime date)? formatDate,
}) {
  final String Function(Money) money =
      formatAmount ?? (Money amount) => amount.toString();
  final String Function(DateTime) date =
      formatDate ?? (DateTime value) => '${value.day}/${value.month}/${value.year}';

  final List<ReminderDraft> drafts = <ReminderDraft>[];

  for (final MilestoneWithContext item in open) {
    final Milestone milestone = item.milestone;
    if (milestone.isCancelled || milestone.isFullyPaid) continue;

    // Work that was never billed is not overdue in any sense a client would
    // accept, so it is never chased.
    if (milestone.stage != MilestoneStage.invoiced) continue;

    final int daysOverdue = milestone.daysOverdueAsOf(asOf);
    final ReminderTone? tone = toneForDaysOverdue(daysOverdue);
    if (tone == null) continue;

    final ReminderTemplate? template = templates
        .where((ReminderTemplate t) => t.tone == tone)
        .firstOrNull;
    if (template == null) continue;

    final DateTime? lastSent = _lastSentAt(log, milestone.id, tone);
    if (lastSent != null && asOf.difference(lastSent) < kResendInterval) {
      continue;
    }

    final ({String subject, String body}) rendered = template.render(
      <String, String>{
        'client': item.client.name,
        'company': item.client.company ?? item.client.name,
        'project': item.project.name,
        'milestone': milestone.title,
        'amount': money(milestone.outstanding),
        'gross': money(milestone.grossAmount),
        'invoice': milestone.invoiceRef ?? milestone.title,
        'days': '$daysOverdue',
        'due_date': date(milestone.dueDate),
        'me': senderName,
      },
    );

    drafts.add(
      ReminderDraft(
        context: item,
        tone: tone,
        subject: rendered.subject,
        body: rendered.body,
        daysOverdue: daysOverdue,
        recipient: item.client.email,
        previouslySentAt: lastSent,
      ),
    );
  }

  // Worst first: the queue doubles as a priority list.
  drafts.sort((ReminderDraft a, ReminderDraft b) =>
      b.daysOverdue.compareTo(a.daysOverdue));
  return drafts;
}

/// The strongest tone earned by [daysOverdue], or null if nothing is due yet.
ReminderTone? toneForDaysOverdue(int daysOverdue) {
  if (daysOverdue >= ReminderTone.formal.thresholdDays) {
    return ReminderTone.formal;
  }
  if (daysOverdue >= ReminderTone.firm.thresholdDays) return ReminderTone.firm;
  if (daysOverdue >= ReminderTone.nudge.thresholdDays) return ReminderTone.nudge;
  return null;
}

DateTime? _lastSentAt(
  List<ReminderLogEntry> log,
  String milestoneId,
  ReminderTone tone,
) {
  DateTime? latest;
  for (final ReminderLogEntry entry in log) {
    if (entry.milestoneId != milestoneId || entry.tone != tone) continue;
    if (latest == null || entry.sentAt.isAfter(latest)) latest = entry.sentAt;
  }
  return latest;
}
