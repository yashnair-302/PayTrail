import 'package:drift/drift.dart';

import '../db/database.dart';

/// Serialises the whole ledger to a plain map and restores it.
///
/// The backup is a logical snapshot (every row of every table as JSON), not a
/// copy of the SQLCipher file: the file is sealed with a key that lives only in
/// this device's Keystore and cannot be opened elsewhere, so a second device
/// could never read it. A logical snapshot is re-imported into whatever
/// encrypted database the other device already has, which is what makes sync
/// across devices possible at all.
///
/// `toJson` / `fromJson` are drift's own, so a row round-trips through exactly
/// the serializer that produced it — no column mapping to drift out of sync with
/// the schema.
class LedgerSnapshotCodec {
  const LedgerSnapshotCodec(this._db);

  final PayTrailDatabase _db;

  /// Bumped only if the snapshot layout itself changes, so an old backup can be
  /// recognised and either migrated or refused rather than half-imported.
  static const int snapshotFormat = 1;

  /// Reads every table into a JSON-safe map.
  Future<Map<String, dynamic>> export() async {
    return <String, dynamic>{
      'format': snapshotFormat,
      'schemaVersion': _db.schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'tables': <String, dynamic>{
        'paymentSources': <Map<String, dynamic>>[
          for (final PaymentSourceRow r in await _db.select(_db.paymentSources).get())
            r.toJson(),
        ],
        'clients': <Map<String, dynamic>>[
          for (final ClientRow r in await _db.select(_db.clients).get()) r.toJson(),
        ],
        'projects': <Map<String, dynamic>>[
          for (final ProjectRow r in await _db.select(_db.projects).get()) r.toJson(),
        ],
        'milestones': <Map<String, dynamic>>[
          for (final MilestoneRow r in await _db.select(_db.milestones).get())
            r.toJson(),
        ],
        'payments': <Map<String, dynamic>>[
          for (final PaymentRow r in await _db.select(_db.payments).get()) r.toJson(),
        ],
        'ingestEvents': <Map<String, dynamic>>[
          for (final IngestEventRow r in await _db.select(_db.ingestEvents).get())
            r.toJson(),
        ],
        'appSettings': <Map<String, dynamic>>[
          for (final AppSettingRow r in await _db.select(_db.appSettings).get())
            r.toJson(),
        ],
        'reminderLog': <Map<String, dynamic>>[
          for (final ReminderLogRow r in await _db.select(_db.reminderLog).get())
            r.toJson(),
        ],
      },
    };
  }

  /// Replaces the local ledger with [snapshot], in one transaction.
  ///
  /// Restore is a full replace, not a merge: a half-applied import would leave
  /// the books in a state no reconciliation could trust. Children are cleared
  /// before parents and parents inserted before children so the foreign keys
  /// hold at every step, and the whole thing is atomic — it either becomes the
  /// backup or stays exactly as it was.
  Future<void> import(Map<String, dynamic> snapshot) async {
    final Object? format = snapshot['format'];
    if (format is! int || format > snapshotFormat) {
      throw FormatException(
        'This backup was made by a newer version of PayTrail and cannot be '
        'restored here.',
      );
    }

    final Map<String, dynamic> tables =
        (snapshot['tables'] as Map<dynamic, dynamic>).cast<String, dynamic>();

    List<Map<String, dynamic>> rows(String key) =>
        ((tables[key] as List<dynamic>?) ?? const <dynamic>[])
            .map((dynamic e) => (e as Map<dynamic, dynamic>).cast<String, dynamic>())
            .toList();

    await _db.transaction(() async {
      // Children first, so no delete orphans a foreign key mid-way.
      await _db.delete(_db.reminderLog).go();
      await _db.delete(_db.payments).go();
      await _db.delete(_db.ingestEvents).go();
      await _db.delete(_db.milestones).go();
      await _db.delete(_db.projects).go();
      await _db.delete(_db.clients).go();
      await _db.delete(_db.appSettings).go();
      await _db.delete(_db.paymentSources).go();

      // Parents first, so every reference resolves as it is inserted.
      for (final Map<String, dynamic> j in rows('paymentSources')) {
        await _db.into(_db.paymentSources).insert(
              PaymentSourceRow.fromJson(j),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final Map<String, dynamic> j in rows('clients')) {
        await _db.into(_db.clients).insert(
              ClientRow.fromJson(j),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final Map<String, dynamic> j in rows('projects')) {
        await _db.into(_db.projects).insert(
              ProjectRow.fromJson(j),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final Map<String, dynamic> j in rows('milestones')) {
        await _db.into(_db.milestones).insert(
              MilestoneRow.fromJson(j),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final Map<String, dynamic> j in rows('payments')) {
        await _db.into(_db.payments).insert(
              PaymentRow.fromJson(j),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final Map<String, dynamic> j in rows('ingestEvents')) {
        await _db.into(_db.ingestEvents).insert(
              IngestEventRow.fromJson(j),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final Map<String, dynamic> j in rows('appSettings')) {
        await _db.into(_db.appSettings).insert(
              AppSettingRow.fromJson(j),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final Map<String, dynamic> j in rows('reminderLog')) {
        await _db.into(_db.reminderLog).insert(
              ReminderLogRow.fromJson(j),
              mode: InsertMode.insertOrReplace,
            );
      }
    });
  }
}
