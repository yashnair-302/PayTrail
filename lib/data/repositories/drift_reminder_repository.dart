import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/reminders/reminder_rules.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../db/database.dart';

/// [ReminderRepository] over the encrypted Drift database.
class DriftReminderRepository implements ReminderRepository {
  DriftReminderRepository(this._db);

  final PayTrailDatabase _db;
  static const Uuid _uuid = Uuid();

  ReminderLogEntry _toEntry(ReminderLogRow row) => ReminderLogEntry(
        id: row.id,
        milestoneId: row.milestoneId,
        clientId: row.clientId,
        tone: row.tone,
        subject: row.subject,
        body: row.body,
        recipient: row.recipient,
        sentAt: row.sentAt,
      );

  @override
  Stream<List<ReminderLogEntry>> watchAll({int limit = 500}) {
    return (_db.select(_db.reminderLog)
          ..orderBy(<OrderClauseGenerator<$ReminderLogTable>>[
            ($ReminderLogTable t) => OrderingTerm.desc(t.sentAt),
          ])
          ..limit(limit))
        .watch()
        .map((List<ReminderLogRow> rows) => rows.map(_toEntry).toList());
  }

  @override
  Stream<List<ReminderLogEntry>> watchForClient(String clientId) {
    return (_db.select(_db.reminderLog)
          ..where(($ReminderLogTable t) => t.clientId.equals(clientId))
          ..orderBy(<OrderClauseGenerator<$ReminderLogTable>>[
            ($ReminderLogTable t) => OrderingTerm.desc(t.sentAt),
          ]))
        .watch()
        .map((List<ReminderLogRow> rows) => rows.map(_toEntry).toList());
  }

  @override
  Future<List<ReminderLogEntry>> getAll() async {
    final List<ReminderLogRow> rows = await _db.select(_db.reminderLog).get();
    return rows.map(_toEntry).toList();
  }

  @override
  Future<String> recordSent({
    required String milestoneId,
    required String clientId,
    required ReminderTone tone,
    required String subject,
    String? body,
    String? recipient,
    DateTime? sentAt,
  }) async {
    final String id = _uuid.v4();
    await _db.into(_db.reminderLog).insert(
          ReminderLogCompanion.insert(
            id: id,
            milestoneId: milestoneId,
            clientId: clientId,
            tone: tone,
            subject: subject,
            // The text as sent, after the user's edits — the log is a record of
            // what went out, not of what the template says today.
            body: Value<String?>(body),
            recipient: Value<String?>(recipient),
            sentAt: sentAt ?? DateTime.now(),
          ),
        );
    return id;
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.reminderLog)
          ..where(($ReminderLogTable t) => t.id.equals(id)))
        .go();
  }
}
