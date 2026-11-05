import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:paytrail/data/backup/backup_crypto.dart';
import 'package:paytrail/data/backup/ledger_snapshot.dart';
import 'package:paytrail/data/db/database.dart';
import 'package:paytrail/data/repositories/drift_ledger_repository.dart';
import 'package:paytrail/domain/entities/milestone.dart';
import 'package:paytrail/domain/entities/payment.dart';
import 'package:paytrail/domain/entities/payment_source.dart';
import 'package:paytrail/domain/money.dart';
import 'package:paytrail/domain/repositories/ledger_repository.dart';

/// Fills a fresh ledger with one client → project → milestone → payment and
/// returns the repository over it.
Future<DriftLedgerRepository> _seed(PayTrailDatabase db) async {
  final DriftLedgerRepository repo = DriftLedgerRepository(db);
  final String clientId =
      await repo.createClient(const ClientDraft(name: 'Acme Studio'));
  final String projectId = await repo.createProject(
    ProjectDraft(
      clientId: clientId,
      name: 'Website revamp',
      defaultSourceId: SourceIds.direct,
      defaultCurrency: 'INR',
    ),
  );
  final String milestoneId = await repo.createMilestone(
    MilestoneDraft(
      projectId: projectId,
      title: 'Phase 1',
      grossAmount: Money(100000, 'INR'),
      dueDate: DateTime(2026, 9, 1),
      sourceId: SourceIds.direct,
      commissionRateBps: 0,
      tdsRateBps: 0,
      stage: MilestoneStage.invoiced,
    ),
  );
  await repo.addPayment(
    PaymentDraft(
      milestoneId: milestoneId,
      amount: Money(60000, 'INR'),
      receivedAt: DateTime(2026, 9, 10),
      method: PaymentMethod.bankTransfer,
    ),
  );
  return repo;
}

void main() {
  group('BackupCrypto', () {
    test('round-trips a snapshot through the right passphrase', () async {
      final Map<String, dynamic> original = <String, dynamic>{
        'format': 1,
        'tables': <String, dynamic>{
          'clients': <Map<String, dynamic>>[
            <String, dynamic>{'id': 'c1', 'name': 'Acme'},
          ],
        },
      };

      final Uint8List blob =
          await BackupCrypto.encryptJson(original, 'correct horse battery');
      final Map<String, dynamic> back =
          await BackupCrypto.decryptJson(blob, 'correct horse battery');

      expect(back, equals(original));
    });

    test('the ciphertext is not the plaintext', () async {
      final Uint8List blob = await BackupCrypto.encryptJson(
        <String, dynamic>{'secret': 'owed 100000'},
        'passphrase1',
      );
      // The sensitive string must not appear in the encrypted bytes.
      expect(String.fromCharCodes(blob).contains('owed'), isFalse);
    });

    test('a wrong passphrase is rejected, not silently wrong', () async {
      final Uint8List blob = await BackupCrypto.encryptJson(
        <String, dynamic>{'a': 1},
        'right-passphrase',
      );
      expect(
        () => BackupCrypto.decryptJson(blob, 'wrong-passphrase'),
        throwsA(isA<BackupPassphraseError>()),
      );
    });

    test('random bytes are not a backup file', () async {
      expect(
        () => BackupCrypto.decryptJson(
          Uint8List.fromList(<int>[1, 2, 3, 4, 5, 6, 7, 8]),
          'whatever',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('backup and restore', () {
    test('a ledger survives export, encrypt, decrypt and import intact',
        () async {
      // Source device: seed it and take an encrypted backup.
      final PayTrailDatabase source = PayTrailDatabase.inMemory();
      await _seed(source);
      final Map<String, dynamic> snapshot =
          await LedgerSnapshotCodec(source).export();
      final Uint8List blob =
          await BackupCrypto.encryptJson(snapshot, 'my-passphrase');

      // Target device: a different, empty ledger.
      final PayTrailDatabase target = PayTrailDatabase.inMemory();
      final DriftLedgerRepository targetRepo = DriftLedgerRepository(target);
      expect((await targetRepo.watchClientSummaries().first), isEmpty);

      // Restore the decrypted snapshot into it.
      final Map<String, dynamic> decrypted =
          await BackupCrypto.decryptJson(blob, 'my-passphrase');
      await LedgerSnapshotCodec(target).import(decrypted);

      // The client, and its outstanding balance, now exist on the target.
      final List<ClientSummary> clients =
          await targetRepo.watchClientSummaries().first;
      expect(clients, hasLength(1));
      expect(clients.single.client.name, 'Acme Studio');
      // Net 100000 billed, 60000 received → 40000 still outstanding.
      expect(clients.single.outstanding.inCurrency('INR').minorUnits, 40000);

      await source.close();
      await target.close();
    });
  });
}
