import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/calendar.dart';
import '../../domain/entities/payment.dart';
import '../../domain/ingest/payment_event.dart';
import '../../domain/ingest/reconciliation.dart';
import '../../domain/money.dart';
import '../../domain/repositories/ingest_repository.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../db/database.dart';

/// [IngestRepository] over the encrypted Drift database.
class DriftIngestRepository implements IngestRepository {
  DriftIngestRepository(this._db, this._ledger);

  final PayTrailDatabase _db;

  /// Used only by [importEvent], which writes the payment through the ledger's
  /// own API so reconciliation of `paidAt` happens exactly once, in one place.
  final LedgerRepository _ledger;

  static const Uuid _uuid = Uuid();

  IngestedEvent _toEvent(IngestEventRow row) {
    return IngestedEvent(
      id: row.id,
      event: PaymentEvent(
        sourceId: row.sourceId,
        channel: row.channel,
        grossAmount: Money(row.grossAmountMinor, row.currency),
        netAmount: row.netAmountMinor == null
            ? null
            : Money(row.netAmountMinor!, row.currency),
        occurredAt: row.occurredAt,
        externalTxnId: row.externalTxnId,
        clientHint: row.clientHint,
        projectHint: row.projectHint,
        description: row.description,
        raw: row.raw,
      ),
      status: row.status,
      createdAt: row.createdAt,
      matchedMilestoneId: row.matchedMilestoneId,
      importedPaymentId: row.importedPaymentId,
      resolvedAt: row.resolvedAt,
    );
  }

  @override
  Future<IntakeSummary> stage(
    List<PaymentEvent> events, {
    List<IngestIssue> issues = const <IngestIssue>[],
  }) async {
    if (events.isEmpty) {
      return IntakeSummary(staged: 0, duplicatesSkipped: 0, issues: issues);
    }

    final Set<String> known = await knownDedupeKeys();
    final DedupeResult screened =
        deduplicate(incoming: events, knownKeys: known);

    if (screened.accepted.isNotEmpty) {
      final DateTime now = DateTime.now();
      await _db.batch((Batch batch) {
        batch.insertAll(
          _db.ingestEvents,
          <IngestEventsCompanion>[
            for (final PaymentEvent event in screened.accepted)
              IngestEventsCompanion.insert(
                id: _uuid.v4(),
                sourceId: event.sourceId,
                channel: event.channel,
                grossAmountMinor: event.grossAmount.minorUnits,
                netAmountMinor: Value<int?>(event.netAmount?.minorUnits),
                currency: event.grossAmount.currency,
                occurredAt: dateOnly(event.occurredAt),
                externalTxnId: Value<String?>(event.externalTxnId),
                clientHint: Value<String?>(event.clientHint),
                projectHint: Value<String?>(event.projectHint),
                description: Value<String?>(event.description),
                raw: event.raw,
                dedupeKey: event.dedupeKey,
                status: IngestStatus.pending,
                createdAt: now,
              ),
          ],
          // Belt and braces alongside the in-Dart screen above: two uploads
          // racing each other would both pass the read, and the unique index
          // is the only thing that can settle it.
          mode: InsertMode.insertOrIgnore,
        );
      });
    }

    return IntakeSummary(
      staged: screened.acceptedCount,
      duplicatesSkipped: screened.duplicateCount,
      issues: issues,
    );
  }

  @override
  Stream<List<IngestedEvent>> watchPending() {
    return (_db.select(_db.ingestEvents)
          ..where(($IngestEventsTable t) =>
              t.status.equalsValue(IngestStatus.pending))
          ..orderBy(<OrderClauseGenerator<$IngestEventsTable>>[
            ($IngestEventsTable t) => OrderingTerm.desc(t.occurredAt),
            ($IngestEventsTable t) => OrderingTerm.desc(t.createdAt),
          ]))
        .watch()
        .map((List<IngestEventRow> rows) => rows.map(_toEvent).toList());
  }

  @override
  Stream<List<IngestedEvent>> watchAll({int limit = 200}) {
    return (_db.select(_db.ingestEvents)
          ..orderBy(<OrderClauseGenerator<$IngestEventsTable>>[
            ($IngestEventsTable t) => OrderingTerm.desc(t.createdAt),
          ])
          ..limit(limit))
        .watch()
        .map((List<IngestEventRow> rows) => rows.map(_toEvent).toList());
  }

  @override
  Future<IngestedEvent?> getEvent(String id) async {
    final IngestEventRow? row = await (_db.select(_db.ingestEvents)
          ..where(($IngestEventsTable t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toEvent(row);
  }

  @override
  Future<Set<String>> knownDedupeKeys() async {
    final JoinedSelectStatement<HasResultSet, dynamic> query =
        _db.selectOnly(_db.ingestEvents)
          ..addColumns(<Expression<Object>>[_db.ingestEvents.dedupeKey]);
    final List<TypedResult> rows = await query.get();
    return rows
        .map((TypedResult row) => row.read(_db.ingestEvents.dedupeKey))
        .whereType<String>()
        .toSet();
  }

  @override
  Future<String> importEvent({
    required String eventId,
    required String milestoneId,
    required Money amount,
    required DateTime receivedAt,
    PaymentMethod method = PaymentMethod.platform,
    String? note,
  }) async {
    final IngestedEvent? event = await getEvent(eventId);
    if (event == null) {
      throw StateError('That imported payment is no longer in the queue.');
    }
    if (event.status == IngestStatus.imported) {
      throw StateError('This payment has already been imported.');
    }

    // Written through the ledger rather than straight to the payments table:
    // addPayment validates the currency, rejects non-positive amounts and
    // reconciles the milestone, and none of that should have a second
    // implementation here.
    final String paymentId = await _ledger.addPayment(
      PaymentDraft(
        milestoneId: milestoneId,
        amount: amount,
        receivedAt: receivedAt,
        method: method,
        reference: event.event.externalTxnId,
        externalTxnId: event.event.externalTxnId,
        ingestSource: event.event.channel,
        note: note,
      ),
    );

    await (_db.update(_db.ingestEvents)
          ..where(($IngestEventsTable t) => t.id.equals(eventId)))
        .write(
      IngestEventsCompanion(
        status: const Value<IngestStatus>(IngestStatus.imported),
        matchedMilestoneId: Value<String?>(milestoneId),
        importedPaymentId: Value<String?>(paymentId),
        resolvedAt: Value<DateTime?>(DateTime.now()),
      ),
    );

    return paymentId;
  }

  @override
  Future<void> ignoreEvent(String eventId) async {
    await (_db.update(_db.ingestEvents)
          ..where(($IngestEventsTable t) => t.id.equals(eventId)))
        .write(
      IngestEventsCompanion(
        status: const Value<IngestStatus>(IngestStatus.ignored),
        resolvedAt: Value<DateTime?>(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> reopenEvent(String eventId) async {
    final IngestedEvent? event = await getEvent(eventId);
    if (event == null) return;
    if (event.status == IngestStatus.imported) {
      // Reopening would offer a second payment for money already recorded.
      // Removing the payment is the user's decision, made on the milestone.
      throw StateError(
        'Remove the imported payment from the milestone first.',
      );
    }
    await (_db.update(_db.ingestEvents)
          ..where(($IngestEventsTable t) => t.id.equals(eventId)))
        .write(
      const IngestEventsCompanion(
        status: Value<IngestStatus>(IngestStatus.pending),
        resolvedAt: Value<DateTime?>(null),
      ),
    );
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await (_db.delete(_db.ingestEvents)
          ..where(($IngestEventsTable t) => t.id.equals(eventId)))
        .go();
  }

  // --- Settings ------------------------------------------------------------

  @override
  Future<String?> getSetting(String key) async {
    final AppSettingRow? row = await (_db.select(_db.appSettings)
          ..where(($AppSettingsTable t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  @override
  Stream<String?> watchSetting(String key) {
    return (_db.select(_db.appSettings)
          ..where(($AppSettingsTable t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((AppSettingRow? row) => row?.value);
  }

  @override
  Future<void> setSetting(String key, String value) async {
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<void> clearSetting(String key) async {
    await (_db.delete(_db.appSettings)
          ..where(($AppSettingsTable t) => t.key.equals(key)))
        .go();
  }
}
