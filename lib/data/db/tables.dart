import 'package:drift/drift.dart';

import '../../domain/entities/milestone.dart';
import '../../domain/entities/payment.dart';
import '../../domain/ingest/payment_event.dart';
import '../../domain/reminders/reminder_rules.dart';

/// The ledger schema.
///
/// Conventions that apply to every table here:
///
/// * **Text primary keys (UUIDv4), not autoincrement integers.** Module 3
///   ingests the same payment from a notification, an email and a CSV, and
///   Module 5 exports rows that may be re-imported. Client-generated ids let a
///   row be created, referenced and deduplicated without a round trip to the
///   database, and they stay stable if data is ever synced to another device.
/// * **Money as integer minor units plus a currency column.** Never a real.
///   See `lib/domain/money.dart` for why.
/// * **Rates as integer basis points.** 20% is 2000 — exact, and comparable.
/// * **`createdAt` / `updatedAt` on every row**, because a financial record
///   that cannot be placed in time is not much of a record.

/// Payment channels and their current deduction rates.
///
/// A table rather than a Dart enum: the plan calls for configurable commission,
/// and users add their own channels. The four built-ins are seeded on first
/// open and flagged so the UI can stop them being deleted out from under the
/// parsers that reference their ids.
@DataClassName('PaymentSourceRow')
class PaymentSources extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();
  TextColumn get displayName => text().withLength(min: 1, max: 64)();
  IntColumn get commissionRateBps => integer().withDefault(const Constant<int>(0))();
  IntColumn get defaultTdsRateBps => integer().withDefault(const Constant<int>(0))();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant<bool>(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant<int>(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('ClientRow')
@TableIndex(name: 'idx_clients_archived', columns: <Symbol>{#archivedAt})
class Clients extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get company => text().withLength(max: 200).nullable()();
  TextColumn get email => text().withLength(max: 320).nullable()();
  TextColumn get phone => text().withLength(max: 40).nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  /// Non-null means archived. Soft delete keeps years of income history — and
  /// therefore the tax export — intact when a client relationship ends.
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('ProjectRow')
@TableIndex(name: 'idx_projects_client', columns: <Symbol>{#clientId})
class Projects extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();

  /// `ON DELETE CASCADE`: deleting a client is an explicit, confirmed action in
  /// the UI, and leaving orphaned projects behind would corrupt every total.
  TextColumn get clientId =>
      text().references(Clients, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();

  /// Prefill for new milestones only; the milestone's own source is what every
  /// report reads, so changing this never rewrites history.
  TextColumn get defaultSourceId =>
      text().references(PaymentSources, #id, onDelete: KeyAction.restrict)();

  TextColumn get defaultCurrency => text().withLength(min: 3, max: 3)();

  /// Platform contract/order id, used by Module 3 to auto-attach payments.
  TextColumn get externalRef => text().withLength(max: 128).nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('MilestoneRow')
@TableIndex(name: 'idx_milestones_project', columns: <Symbol>{#projectId})
@TableIndex(name: 'idx_milestones_due', columns: <Symbol>{#dueDate})
@TableIndex(name: 'idx_milestones_source', columns: <Symbol>{#sourceId})
class Milestones extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();

  TextColumn get projectId =>
      text().references(Projects, #id, onDelete: KeyAction.cascade)();

  TextColumn get title => text().withLength(min: 1, max: 200)();

  /// Billed amount in minor units. Deductions are applied on read so the
  /// originally agreed figure is never lost.
  IntColumn get grossAmountMinor => integer()();

  TextColumn get currency => text().withLength(min: 3, max: 3)();

  /// Stored at local midnight: a due date is a calendar date, not an instant.
  DateTimeColumn get dueDate => dateTime()();

  TextColumn get sourceId =>
      text().references(PaymentSources, #id, onDelete: KeyAction.restrict)();

  /// Rates snapshotted at creation, so historical rows keep reconciling after
  /// a platform changes its commission. See [Milestone.commissionRateBps].
  IntColumn get commissionRateBps => integer().withDefault(const Constant<int>(0))();
  IntColumn get tdsRateBps => integer().withDefault(const Constant<int>(0))();

  /// pending | invoiced | cancelled. `overdue` and `paid` are derived on read
  /// and deliberately not stored; see [MilestoneStage].
  TextColumn get stage => textEnum<MilestoneStage>()();

  TextColumn get invoiceRef => text().withLength(max: 64).nullable()();
  DateTimeColumn get invoicedAt => dateTime().nullable()();

  /// Set by the repository when payments first cover the net amount, cleared if
  /// a payment is later removed. Cached rather than derived because Module 5's
  /// tax export needs to know *when* a milestone settled, which the payment
  /// rows alone do not say once there are several of them.
  DateTimeColumn get paidAt => dateTime().nullable()();

  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('PaymentRow')
@TableIndex(name: 'idx_payments_milestone', columns: <Symbol>{#milestoneId})
@TableIndex(name: 'idx_payments_received', columns: <Symbol>{#receivedAt})
// Partial unique index: the database itself refuses a second row for the same
// platform transaction, so Module 3 cannot double-count a payment that arrives
// by notification and again by statement. NULL external ids are exempt, which
// is what lets a user record several manual part payments on one milestone.
@TableIndex.sql('''
  CREATE UNIQUE INDEX idx_payments_external_txn
    ON payments (external_txn_id)
    WHERE external_txn_id IS NOT NULL
''')
class Payments extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();

  TextColumn get milestoneId =>
      text().references(Milestones, #id, onDelete: KeyAction.cascade)();

  /// Amount received, net of platform deductions, in minor units.
  IntColumn get amountMinor => integer()();

  TextColumn get currency => text().withLength(min: 3, max: 3)();
  DateTimeColumn get receivedAt => dateTime()();

  TextColumn get method => textEnum<PaymentMethod>()();

  /// UTR, cheque number, or whatever the user can reconcile against.
  TextColumn get reference => text().withLength(max: 128).nullable()();

  /// Platform transaction id; part of the Module 3 dedupe key.
  TextColumn get externalTxnId => text().withLength(max: 128).nullable()();

  /// Which ingestion path wrote this row — manual for everything Module 1
  /// creates. Kept from the first migration so automatic matches are auditable.
  TextColumn get ingestSource => textEnum<IngestSource>()();

  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// A payment the app parsed from a statement, email or notification, waiting
/// for the user to confirm it.
///
/// Nothing from Module 3 writes straight into `payments`. A regex against a
/// notification is a guess, and a guess that silently becomes a financial
/// record is worse than no automation at all: the user would have no way to
/// know which figures they had actually verified. Events land here, the user
/// reviews them, and only confirmation creates the payment row.
///
/// No foreign key on `source_id`: this table holds raw input, and a statement
/// naming a platform the ledger has never heard of should still be storable and
/// visible rather than rejected by the database.
@DataClassName('IngestEventRow')
@TableIndex(name: 'idx_ingest_status', columns: <Symbol>{#status})
@TableIndex(name: 'idx_ingest_occurred', columns: <Symbol>{#occurredAt})
// The dedupe key is unique across the whole table, so re-importing an
// overlapping date range is refused by the database itself rather than by the
// code remembering to check.
@TableIndex(
  name: 'idx_ingest_dedupe',
  columns: <Symbol>{#dedupeKey},
  unique: true,
)
class IngestEvents extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();

  TextColumn get sourceId => text().withLength(min: 1, max: 64)();

  /// Which of the three ingestion paths produced it.
  TextColumn get channel => textEnum<IngestSource>()();

  IntColumn get grossAmountMinor => integer()();

  /// Net as the platform stated it; null when it only quoted one figure.
  IntColumn get netAmountMinor => integer().nullable()();

  TextColumn get currency => text().withLength(min: 3, max: 3)();
  DateTimeColumn get occurredAt => dateTime()();

  TextColumn get externalTxnId => text().withLength(max: 128).nullable()();
  TextColumn get clientHint => text().withLength(max: 200).nullable()();
  TextColumn get projectHint => text().withLength(max: 128).nullable()();
  TextColumn get description => text().nullable()();

  /// The original CSV row or message text, kept so a mis-parse can be
  /// diagnosed from the record instead of by re-downloading the statement.
  TextColumn get raw => text()();

  /// source + external id + amount + date. See `PaymentEvent.dedupeKey`.
  TextColumn get dedupeKey => text().withLength(min: 1, max: 400)();

  /// pending | imported | ignored.
  TextColumn get status => textEnum<IngestStatus>()();

  /// The milestone the user attached it to, once imported.
  ///
  /// `SET NULL` rather than cascade: if the milestone is later deleted, the
  /// record that this event was seen and handled must survive, or the next
  /// import would offer it again as new.
  TextColumn get matchedMilestoneId =>
      text().nullable().references(Milestones, #id, onDelete: KeyAction.setNull)();

  TextColumn get importedPaymentId => text().withLength(max: 64).nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Small key/value store for app-level settings.
///
/// Lives in the encrypted database rather than shared preferences because what
/// it holds — which data sources the user consented to, when the mailbox was
/// last read — is a record of access to their financial data and deserves the
/// same protection as the ledger itself.
@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get key => text().withLength(min: 1, max: 128)();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}

/// Every reminder the user actually sent.
///
/// Written when a draft is dispatched, not when it is generated. Two jobs: it
/// stops the queue re-offering the same tone every time the screen opens, and
/// it gives the client record a chase history — which is what turns "I think I
/// followed up" into something a user can point at.
@DataClassName('ReminderLogRow')
@TableIndex(name: 'idx_reminders_milestone', columns: <Symbol>{#milestoneId})
@TableIndex(name: 'idx_reminders_client', columns: <Symbol>{#clientId})
@TableIndex(name: 'idx_reminders_sent', columns: <Symbol>{#sentAt})
class ReminderLog extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();

  TextColumn get milestoneId =>
      text().references(Milestones, #id, onDelete: KeyAction.cascade)();

  /// Denormalised so the client's chase history survives a milestone being
  /// deleted, and so the history can be read without a join.
  TextColumn get clientId =>
      text().references(Clients, #id, onDelete: KeyAction.cascade)();

  /// nudge | firm | formal.
  TextColumn get tone => textEnum<ReminderTone>()();

  TextColumn get subject => text()();

  /// The text as it was actually sent, after any edits the user made. Stored so
  /// the record is of what went out, not of what the template would produce
  /// today.
  TextColumn get body => text().nullable()();

  TextColumn get recipient => text().withLength(max: 320).nullable()();
  DateTimeColumn get sentAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
