import '../reminders/reminder_rules.dart';

/// Storage for the reminder log.
///
/// Read-and-append only: a reminder that was sent happened, and the app has no
/// business editing that record afterwards. Deletion exists for a mistaken
/// entry, nothing more.
abstract interface class ReminderRepository {
  Stream<List<ReminderLogEntry>> watchAll({int limit = 500});

  /// One client's chase history, newest first.
  Stream<List<ReminderLogEntry>> watchForClient(String clientId);

  /// The whole log, for the rule evaluator's suppression check.
  Future<List<ReminderLogEntry>> getAll();

  /// Records that a reminder actually went out.
  ///
  /// Called after the mail app has been handed the draft, never when the draft
  /// is merely generated — the log has to mean "this was sent", or the
  /// suppression rules would hide reminders the client never received.
  Future<String> recordSent({
    required String milestoneId,
    required String clientId,
    required ReminderTone tone,
    required String subject,
    String? body,
    String? recipient,
    DateTime? sentAt,
  });

  Future<void> delete(String id);
}
