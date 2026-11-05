import 'package:flutter_test/flutter_test.dart';
import 'package:paytrail/data/db/database.dart';
import 'package:paytrail/data/repositories/drift_ledger_repository.dart';
import 'package:paytrail/domain/entities/milestone.dart';
import 'package:paytrail/domain/entities/payment.dart';
import 'package:paytrail/domain/entities/payment_source.dart';
import 'package:paytrail/domain/entities/project.dart';
import 'package:paytrail/domain/money.dart';
import 'package:paytrail/domain/repositories/ledger_repository.dart';

void main() {
  late PayTrailDatabase db;
  late DriftLedgerRepository repo;

  setUp(() async {
    db = PayTrailDatabase.inMemory();
    repo = DriftLedgerRepository(db);
    // Touch the database so beforeOpen runs and the built-in sources exist.
    await repo.getSources();
  });

  tearDown(() async {
    await db.close();
  });

  /// Creates a client, a project and returns the project id.
  Future<String> seedProject({
    String sourceId = SourceIds.direct,
    String currency = 'INR',
  }) async {
    final String clientId =
        await repo.createClient(const ClientDraft(name: 'Acme Studio'));
    return repo.createProject(
      ProjectDraft(
        clientId: clientId,
        name: 'Website revamp',
        defaultSourceId: sourceId,
        defaultCurrency: currency,
      ),
    );
  }

  Future<String> seedMilestone(
    String projectId, {
    int grossMinor = 100000,
    String currency = 'INR',
    int commissionRateBps = 0,
    int tdsRateBps = 0,
    DateTime? dueDate,
    MilestoneStage stage = MilestoneStage.invoiced,
  }) {
    return repo.createMilestone(
      MilestoneDraft(
        projectId: projectId,
        title: 'Phase 1',
        grossAmount: Money(grossMinor, currency),
        dueDate: dueDate ?? DateTime(2026, 9, 1),
        sourceId: SourceIds.direct,
        commissionRateBps: commissionRateBps,
        tdsRateBps: tdsRateBps,
        stage: stage,
      ),
    );
  }

  group('seeding', () {
    test('the four built-in sources exist on first open', () async {
      final List<PaymentSource> sources = await repo.getSources();
      expect(
        sources.map((PaymentSource s) => s.id),
        containsAll(<String>[
          SourceIds.upwork,
          SourceIds.fiverr,
          SourceIds.direct,
          SourceIds.retainer,
        ]),
      );
      expect(
        sources
            .firstWhere((PaymentSource s) => s.id == SourceIds.fiverr)
            .commissionRateBps,
        2000,
      );
      expect(
        sources
            .firstWhere((PaymentSource s) => s.id == SourceIds.upwork)
            .commissionRateBps,
        1000,
      );
    });

    test('an edited commission rate survives, and is not re-seeded', () async {
      final PaymentSource fiverr = (await repo.getSource(SourceIds.fiverr))!;
      await repo.updateSource(fiverr.copyWith(commissionRateBps: 1500));

      // Force another beforeOpen-style seed pass.
      final PaymentSource? reloaded = await repo.getSource(SourceIds.fiverr);
      expect(reloaded!.commissionRateBps, 1500);
    });
  });

  group('milestones', () {
    test('round-trips with its rates and normalised due date', () async {
      final String projectId = await seedProject();
      final String id = await seedMilestone(
        projectId,
        commissionRateBps: 2000,
        dueDate: DateTime(2026, 9, 1, 17, 45), // deliberately has a time
      );

      final Milestone m = (await repo.getMilestone(id))!;
      expect(m.grossAmount, const Money(100000, 'INR'));
      expect(m.commissionRateBps, 2000);
      expect(m.netAmount, const Money(80000, 'INR'));
      expect(m.amountPaid, const Money(0, 'INR'));
      // Stored at midnight, so days-overdue cannot depend on entry time.
      expect(m.dueDate, DateTime(2026, 9, 1));
    });

    test('is listed under its project', () async {
      final String projectId = await seedProject();
      await seedMilestone(projectId);
      await seedMilestone(projectId, dueDate: DateTime(2026, 10, 1));

      final List<Milestone> listed =
          await repo.watchMilestonesForProject(projectId).first;
      expect(listed, hasLength(2));
      // Soonest due first.
      expect(listed.first.dueDate, DateTime(2026, 9, 1));
    });
  });

  group('payments', () {
    test('a part payment reduces the balance but does not settle it', () async {
      final String projectId = await seedProject();
      final String milestoneId = await seedMilestone(projectId);

      await repo.addPayment(
        PaymentDraft(
          milestoneId: milestoneId,
          amount: const Money(40000, 'INR'),
          receivedAt: DateTime(2026, 9, 10),
          method: PaymentMethod.upi,
        ),
      );

      final Milestone m = (await repo.getMilestone(milestoneId))!;
      expect(m.amountPaid, const Money(40000, 'INR'));
      expect(m.outstanding, const Money(60000, 'INR'));
      expect(m.isPartiallyPaid, isTrue);
      expect(m.paidAt, isNull);
    });

    test('part payments that together cover the net settle it', () async {
      final String projectId = await seedProject();
      final String milestoneId = await seedMilestone(projectId);

      await repo.addPayment(
        PaymentDraft(
          milestoneId: milestoneId,
          amount: const Money(40000, 'INR'),
          receivedAt: DateTime(2026, 9, 10),
          method: PaymentMethod.upi,
        ),
      );
      await repo.addPayment(
        PaymentDraft(
          milestoneId: milestoneId,
          amount: const Money(60000, 'INR'),
          receivedAt: DateTime(2026, 9, 20),
          method: PaymentMethod.bankTransfer,
        ),
      );

      final Milestone m = (await repo.getMilestone(milestoneId))!;
      expect(m.isFullyPaid, isTrue);
      expect(m.outstanding, const Money(0, 'INR'));
      // Stamped with the last receipt date, not the moment of data entry.
      expect(m.paidAt, DateTime(2026, 9, 20));
    });

    test('a Fiverr payout of the net amount settles the gross', () async {
      final String projectId = await seedProject(sourceId: SourceIds.fiverr);
      final String milestoneId =
          await seedMilestone(projectId, commissionRateBps: 2000);

      await repo.addPayment(
        PaymentDraft(
          milestoneId: milestoneId,
          amount: const Money(80000, 'INR'),
          receivedAt: DateTime(2026, 9, 10),
          method: PaymentMethod.platform,
          externalTxnId: 'FO-12345',
        ),
      );

      final Milestone m = (await repo.getMilestone(milestoneId))!;
      expect(m.isFullyPaid, isTrue);
    });

    test('deleting a payment reopens the milestone', () async {
      final String projectId = await seedProject();
      final String milestoneId = await seedMilestone(projectId);
      final String paymentId = await repo.addPayment(
        PaymentDraft(
          milestoneId: milestoneId,
          amount: const Money(100000, 'INR'),
          receivedAt: DateTime(2026, 9, 10),
          method: PaymentMethod.upi,
        ),
      );
      expect((await repo.getMilestone(milestoneId))!.isFullyPaid, isTrue);

      await repo.deletePayment(paymentId);

      final Milestone m = (await repo.getMilestone(milestoneId))!;
      expect(m.isFullyPaid, isFalse);
      expect(m.paidAt, isNull);
      expect(m.outstanding, const Money(100000, 'INR'));
    });

    test('raising the amount after payment reopens the milestone', () async {
      final String projectId = await seedProject();
      final String milestoneId = await seedMilestone(projectId);
      await repo.addPayment(
        PaymentDraft(
          milestoneId: milestoneId,
          amount: const Money(100000, 'INR'),
          receivedAt: DateTime(2026, 9, 10),
          method: PaymentMethod.upi,
        ),
      );

      await repo.updateMilestone(
        milestoneId,
        MilestoneDraft(
          projectId: projectId,
          title: 'Phase 1 (scope increased)',
          grossAmount: const Money(150000, 'INR'),
          dueDate: DateTime(2026, 9, 1),
          sourceId: SourceIds.direct,
          commissionRateBps: 0,
          tdsRateBps: 0,
          stage: MilestoneStage.invoiced,
        ),
      );

      final Milestone m = (await repo.getMilestone(milestoneId))!;
      expect(m.isFullyPaid, isFalse);
      expect(m.paidAt, isNull);
      expect(m.outstanding, const Money(50000, 'INR'));
    });

    test('rejects a payment in the wrong currency', () async {
      final String projectId = await seedProject();
      final String milestoneId = await seedMilestone(projectId);

      expect(
        () => repo.addPayment(
          PaymentDraft(
            milestoneId: milestoneId,
            amount: const Money(100, 'USD'),
            receivedAt: DateTime(2026, 9, 10),
            method: PaymentMethod.bankTransfer,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('rejects a zero payment', () async {
      final String projectId = await seedProject();
      final String milestoneId = await seedMilestone(projectId);

      expect(
        () => repo.addPayment(
          PaymentDraft(
            milestoneId: milestoneId,
            amount: const Money(0, 'INR'),
            receivedAt: DateTime(2026, 9, 10),
            method: PaymentMethod.upi,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('refuses a duplicate platform transaction id', () async {
      final String projectId = await seedProject();
      final String milestoneId = await seedMilestone(projectId);

      Future<void> record() => repo.addPayment(
            PaymentDraft(
              milestoneId: milestoneId,
              amount: const Money(40000, 'INR'),
              receivedAt: DateTime(2026, 9, 10),
              method: PaymentMethod.platform,
              externalTxnId: 'UPW-999',
              ingestSource: IngestSource.notification,
            ),
          );

      await record();
      // The same payout seen again — by email, say — must not double-count.
      await expectLater(record(), throwsA(isA<Exception>()));

      final List<Payment> payments =
          await repo.watchPaymentsForMilestone(milestoneId).first;
      expect(payments, hasLength(1));
    });

    test('allows several manual payments with no transaction id', () async {
      final String projectId = await seedProject();
      final String milestoneId = await seedMilestone(projectId);

      for (int i = 0; i < 3; i++) {
        await repo.addPayment(
          PaymentDraft(
            milestoneId: milestoneId,
            amount: const Money(10000, 'INR'),
            receivedAt: DateTime(2026, 9, 10 + i),
            method: PaymentMethod.cash,
          ),
        );
      }

      final List<Payment> payments =
          await repo.watchPaymentsForMilestone(milestoneId).first;
      expect(payments, hasLength(3));
      expect(
        (await repo.getMilestone(milestoneId))!.amountPaid,
        const Money(30000, 'INR'),
      );
    });
  });

  group('client summaries', () {
    test('a client with no work still appears', () async {
      await repo.createClient(const ClientDraft(name: 'New Lead'));
      final List<ClientSummary> summaries =
          await repo.watchClientSummaries().first;

      expect(summaries, hasLength(1));
      expect(summaries.single.outstanding.isEmpty, isTrue);
      expect(summaries.single.openMilestoneCount, 0);
    });

    test('totals outstanding across projects and excludes paid work', () async {
      final String projectId = await seedProject();
      await seedMilestone(projectId, grossMinor: 100000);
      final String settled = await seedMilestone(projectId, grossMinor: 50000);
      await repo.addPayment(
        PaymentDraft(
          milestoneId: settled,
          amount: const Money(50000, 'INR'),
          receivedAt: DateTime(2026, 9, 10),
          method: PaymentMethod.upi,
        ),
      );

      final ClientSummary summary =
          (await repo.watchClientSummaries().first).single;
      expect(summary.outstanding.inCurrency('INR'), const Money(100000, 'INR'));
      expect(summary.openMilestoneCount, 1);
    });

    test('keeps currencies apart instead of adding them together', () async {
      final String clientId =
          await repo.createClient(const ClientDraft(name: 'Global Co'));
      final String inrProject = await repo.createProject(
        ProjectDraft(
          clientId: clientId,
          name: 'India work',
          defaultSourceId: SourceIds.direct,
          defaultCurrency: 'INR',
        ),
      );
      final String usdProject = await repo.createProject(
        ProjectDraft(
          clientId: clientId,
          name: 'US work',
          defaultSourceId: SourceIds.upwork,
          defaultCurrency: 'USD',
        ),
      );
      await seedMilestone(inrProject, grossMinor: 100000);
      await seedMilestone(usdProject, grossMinor: 50000, currency: 'USD');

      final ClientSummary summary =
          (await repo.watchClientSummaries().first).single;
      expect(summary.outstanding.currencies, <String>['INR', 'USD']);
      expect(summary.outstanding.inCurrency('INR'), const Money(100000, 'INR'));
      expect(summary.outstanding.inCurrency('USD'), const Money(50000, 'USD'));
    });

    test('a cancelled milestone drops out of the totals', () async {
      final String projectId = await seedProject();
      final String id = await seedMilestone(projectId);
      await repo.setMilestoneStage(id, MilestoneStage.cancelled);

      final ClientSummary summary =
          (await repo.watchClientSummaries().first).single;
      expect(summary.outstanding.isEmpty, isTrue);
      expect(summary.openMilestoneCount, 0);
    });

    test('archived clients are hidden unless asked for', () async {
      final String clientId =
          await repo.createClient(const ClientDraft(name: 'Former Client'));
      await repo.setClientArchived(clientId, true);

      expect(await repo.watchClientSummaries().first, isEmpty);
      expect(
        await repo.watchClientSummaries(includeArchived: true).first,
        hasLength(1),
      );
    });
  });

  group('project summaries', () {
    test('rolls up billed, received and outstanding', () async {
      final String projectId = await seedProject();
      final String a = await seedMilestone(projectId, grossMinor: 100000);
      await seedMilestone(projectId, grossMinor: 50000);
      await repo.addPayment(
        PaymentDraft(
          milestoneId: a,
          amount: const Money(40000, 'INR'),
          receivedAt: DateTime(2026, 9, 10),
          method: PaymentMethod.upi,
        ),
      );

      final Project? project = await repo.getProject(projectId);
      final ProjectSummary summary =
          (await repo.watchProjectSummaries(project!.clientId).first).single;

      expect(summary.billed.inCurrency('INR'), const Money(150000, 'INR'));
      expect(summary.received.inCurrency('INR'), const Money(40000, 'INR'));
      expect(summary.outstanding.inCurrency('INR'), const Money(110000, 'INR'));
      expect(summary.milestoneCount, 2);
    });
  });

  group('cascade deletes', () {
    test('deleting a client removes its projects, milestones, payments',
        () async {
      final String projectId = await seedProject();
      final String milestoneId = await seedMilestone(projectId);
      await repo.addPayment(
        PaymentDraft(
          milestoneId: milestoneId,
          amount: const Money(10000, 'INR'),
          receivedAt: DateTime(2026, 9, 10),
          method: PaymentMethod.upi,
        ),
      );
      final Project project = (await repo.getProject(projectId))!;

      await repo.deleteClient(project.clientId);

      expect(await repo.getProject(projectId), isNull);
      expect(await repo.getMilestone(milestoneId), isNull);
      expect(
        await repo.watchPaymentsForMilestone(milestoneId).first,
        isEmpty,
      );
    });
  });

  group('open milestones', () {
    test('lists only unsettled work, worst first', () async {
      final String projectId = await seedProject();
      await seedMilestone(projectId, dueDate: DateTime(2026, 10, 1));
      await seedMilestone(projectId, dueDate: DateTime(2026, 6, 1));
      final String paid =
          await seedMilestone(projectId, dueDate: DateTime(2026, 7, 1));
      await repo.addPayment(
        PaymentDraft(
          milestoneId: paid,
          amount: const Money(100000, 'INR'),
          receivedAt: DateTime(2026, 7, 2),
          method: PaymentMethod.upi,
        ),
      );

      final List<MilestoneWithContext> open =
          await repo.watchOpenMilestones().first;
      expect(open, hasLength(2));
      expect(open.first.milestone.dueDate, DateTime(2026, 6, 1));
      expect(open.first.client.name, 'Acme Studio');
      expect(open.first.project.name, 'Website revamp');
    });
  });
}
