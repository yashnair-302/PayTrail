import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paytrail/data/db/database.dart';
import 'package:paytrail/data/repositories/drift_ledger_repository.dart';
import 'package:paytrail/domain/calendar.dart';
import 'package:paytrail/domain/entities/milestone.dart';
import 'package:paytrail/domain/entities/payment.dart';
import 'package:paytrail/domain/entities/payment_source.dart';
import 'package:paytrail/domain/money.dart';
import 'package:paytrail/domain/repositories/ledger_repository.dart';
import 'package:paytrail/presentation/providers/ledger_providers.dart';
import 'package:paytrail/presentation/screens/client_list_screen.dart';
import 'package:paytrail/presentation/theme.dart';

/// Widget tests over the real repository and an in-memory database.
///
/// No mock repository: the point of these is that the screens agree with the
/// queries, and a hand-written fake would only prove the screens agree with
/// the fake.
void main() {
  late PayTrailDatabase db;
  late DriftLedgerRepository repo;

  setUp(() async {
    db = PayTrailDatabase.inMemory();
    repo = DriftLedgerRepository(db);
    await repo.getSources();
  });

  tearDown(() async {
    await db.close();
  });

  Widget wrap(Widget child) {
    return ProviderScope(
      overrides: [ledgerRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        theme: buildTheme(Brightness.light),
        home: child,
      ),
    );
  }

  /// Unmounts the tree and lets drift's cleanup run before the test ends.
  ///
  /// Cancelling a drift query stream schedules a zero-duration timer to close
  /// the store. Without pumping once after the ProviderScope is disposed, that
  /// timer is still pending at teardown and the test framework fails the test.
  Future<void> teardownTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    // A bare pump() does not advance the fake clock, so the zero-duration
    // timer would still be queued; elapse a little so it actually fires.
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('shows the empty state before any client exists', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const ClientListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('No clients yet'), findsOneWidget);
    expect(find.text('Add your first client'), findsOneWidget);

    await teardownTree(tester);
  });

  testWidgets('lists a client with its outstanding total', (
    WidgetTester tester,
  ) async {
    final String clientId =
        await repo.createClient(const ClientDraft(name: 'Acme Studio'));
    final String projectId = await repo.createProject(
      ProjectDraft(
        clientId: clientId,
        name: 'Website revamp',
        defaultSourceId: SourceIds.fiverr,
        defaultCurrency: 'INR',
      ),
    );
    await repo.createMilestone(
      MilestoneDraft(
        projectId: projectId,
        title: 'Phase 1',
        grossAmount: const Money(100000, 'INR'), // 1,000.00 gross
        dueDate: today().add(const Duration(days: 10)),
        sourceId: SourceIds.fiverr,
        commissionRateBps: 2000, // 20% commission
        tdsRateBps: 0,
        stage: MilestoneStage.invoiced,
      ),
    );

    await tester.pumpWidget(wrap(const ClientListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Acme Studio'), findsOneWidget);
    expect(find.text('1 open milestone'), findsOneWidget);
    // Net of the 20% Fiverr cut — the figure that will actually arrive.
    expect(find.textContaining('800.00'), findsOneWidget);

    await teardownTree(tester);
  });

  testWidgets('an overdue client is flagged with its worst age', (
    WidgetTester tester,
  ) async {
    final String clientId =
        await repo.createClient(const ClientDraft(name: 'Late Payer'));
    final String projectId = await repo.createProject(
      ProjectDraft(
        clientId: clientId,
        name: 'Brand work',
        defaultSourceId: SourceIds.direct,
        defaultCurrency: 'INR',
      ),
    );
    await repo.createMilestone(
      MilestoneDraft(
        projectId: projectId,
        title: 'Logo',
        grossAmount: const Money(50000, 'INR'),
        dueDate: today().subtract(const Duration(days: 45)),
        sourceId: SourceIds.direct,
        commissionRateBps: 0,
        tdsRateBps: 0,
        stage: MilestoneStage.invoiced,
      ),
    );

    await tester.pumpWidget(wrap(const ClientListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('1 milestone overdue · oldest 45 days'), findsOneWidget);

    await teardownTree(tester);
  });

  testWidgets('the list updates itself when a payment settles the work', (
    WidgetTester tester,
  ) async {
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
        grossAmount: const Money(100000, 'INR'),
        dueDate: today().add(const Duration(days: 10)),
        sourceId: SourceIds.direct,
        commissionRateBps: 0,
        tdsRateBps: 0,
        stage: MilestoneStage.invoiced,
      ),
    );

    await tester.pumpWidget(wrap(const ClientListScreen()));
    await tester.pumpAndSettle();
    expect(find.text('1 open milestone'), findsOneWidget);

    // No screen asks for a refresh: the query stream carries the change.
    await repo.addPayment(
      PaymentDraft(
        milestoneId: milestoneId,
        amount: const Money(100000, 'INR'),
        receivedAt: today(),
        method: PaymentMethod.upi,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nothing outstanding'), findsOneWidget);
    expect(find.text('Settled'), findsOneWidget);

    await teardownTree(tester);
  });
}
