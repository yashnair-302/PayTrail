import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/calendar.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_source.dart';
import '../../domain/entities/project.dart';
import '../../domain/export/income_report.dart';
import '../../domain/money.dart';
import '../../domain/money_bag.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../db/database.dart';

/// One joined row: a milestone with its project, client and received total.
///
/// The ledger has exactly one shape of read — "milestones, with enough context
/// to interpret them" — and the client list, project list, dashboard and
/// reminder queue are all groupings of it. Fetching that shape once and
/// grouping in Dart keeps a single definition of what counts as outstanding,
/// rather than one subtly different `SUM(...)` per screen.
class _LedgerRow {
  const _LedgerRow({
    required this.client,
    this.project,
    this.milestone,
  });

  final Client client;
  final Project? project;
  final Milestone? milestone;
}

/// [LedgerRepository] over the encrypted Drift database.
class DriftLedgerRepository implements LedgerRepository {
  DriftLedgerRepository(this._db);

  final PayTrailDatabase _db;
  static const Uuid _uuid = Uuid();

  // --- Mapping -------------------------------------------------------------

  Client _toClient(ClientRow row) => Client(
        id: row.id,
        name: row.name,
        company: row.company,
        email: row.email,
        phone: row.phone,
        notes: row.notes,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        archivedAt: row.archivedAt,
      );

  Project _toProject(ProjectRow row) => Project(
        id: row.id,
        clientId: row.clientId,
        name: row.name,
        description: row.description,
        defaultSourceId: row.defaultSourceId,
        defaultCurrency: row.defaultCurrency,
        externalRef: row.externalRef,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        archivedAt: row.archivedAt,
      );

  Milestone _toMilestone(MilestoneRow row, int paidMinor) => Milestone(
        id: row.id,
        projectId: row.projectId,
        title: row.title,
        grossAmount: Money(row.grossAmountMinor, row.currency),
        dueDate: row.dueDate,
        sourceId: row.sourceId,
        commissionRateBps: row.commissionRateBps,
        tdsRateBps: row.tdsRateBps,
        stage: row.stage,
        amountPaid: Money(paidMinor, row.currency),
        invoiceRef: row.invoiceRef,
        invoicedAt: row.invoicedAt,
        paidAt: row.paidAt,
        notes: row.notes,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  Payment _toPayment(PaymentRow row) => Payment(
        id: row.id,
        milestoneId: row.milestoneId,
        amount: Money(row.amountMinor, row.currency),
        receivedAt: row.receivedAt,
        method: row.method,
        reference: row.reference,
        externalTxnId: row.externalTxnId,
        ingestSource: row.ingestSource,
        note: row.note,
        createdAt: row.createdAt,
      );

  PaymentSource _toSource(PaymentSourceRow row) => PaymentSource(
        id: row.id,
        displayName: row.displayName,
        commissionRateBps: row.commissionRateBps,
        defaultTdsRateBps: row.defaultTdsRateBps,
        isBuiltIn: row.isBuiltIn,
        sortOrder: row.sortOrder,
      );

  // --- The one joined read -------------------------------------------------

  /// Streams clients with their projects, milestones and received totals.
  ///
  /// Left joins throughout, so a client with no projects and a project with no
  /// milestones both still appear — a brand-new client must be visible in the
  /// list before any work is added to it.
  Stream<List<_LedgerRow>> _watchLedger({
    String? clientId,
    String? projectId,
    bool includeArchivedClients = false,
    bool includeArchivedProjects = false,
  }) {
    final Expression<int> paidMinor = _db.payments.amountMinor.sum();

    final JoinedSelectStatement<HasResultSet, dynamic> query =
        _db.select(_db.clients).join(<Join<HasResultSet, dynamic>>[
      leftOuterJoin(
        _db.projects,
        _db.projects.clientId.equalsExp(_db.clients.id) &
            (includeArchivedProjects
                ? const Constant<bool>(true)
                : _db.projects.archivedAt.isNull()),
      ),
      leftOuterJoin(
        _db.milestones,
        _db.milestones.projectId.equalsExp(_db.projects.id),
      ),
      leftOuterJoin(
        _db.payments,
        _db.payments.milestoneId.equalsExp(_db.milestones.id),
      ),
    ]);

    query.addColumns(<Expression<Object>>[paidMinor]);
    // Grouping by all three ids collapses the payment fan-out back to one row
    // per milestone while keeping clients and projects that have none.
    query.groupBy(<Expression<Object>>[
      _db.clients.id,
      _db.projects.id,
      _db.milestones.id,
    ]);

    final List<Expression<bool>> conditions = <Expression<bool>>[
      if (!includeArchivedClients) _db.clients.archivedAt.isNull(),
      if (clientId != null) _db.clients.id.equals(clientId),
      if (projectId != null) _db.projects.id.equals(projectId),
    ];
    if (conditions.isNotEmpty) {
      query.where(conditions.reduce(
        (Expression<bool> a, Expression<bool> b) => a & b,
      ));
    }

    return query.watch().map((List<TypedResult> rows) {
      return rows.map((TypedResult row) {
        final ProjectRow? projectRow = row.readTableOrNull(_db.projects);
        final MilestoneRow? milestoneRow = row.readTableOrNull(_db.milestones);
        return _LedgerRow(
          client: _toClient(row.readTable(_db.clients)),
          project: projectRow == null ? null : _toProject(projectRow),
          milestone: milestoneRow == null
              ? null
              : _toMilestone(milestoneRow, row.read(paidMinor) ?? 0),
        );
      }).toList();
    });
  }

  // --- Sources -------------------------------------------------------------

  @override
  Stream<List<PaymentSource>> watchSources() {
    return (_db.select(_db.paymentSources)
          ..orderBy(<OrderClauseGenerator<$PaymentSourcesTable>>[
            ($PaymentSourcesTable t) => OrderingTerm.asc(t.sortOrder),
            ($PaymentSourcesTable t) => OrderingTerm.asc(t.displayName),
          ]))
        .watch()
        .map((List<PaymentSourceRow> rows) => rows.map(_toSource).toList());
  }

  @override
  Future<List<PaymentSource>> getSources() async {
    final List<PaymentSourceRow> rows = await (_db.select(_db.paymentSources)
          ..orderBy(<OrderClauseGenerator<$PaymentSourcesTable>>[
            ($PaymentSourcesTable t) => OrderingTerm.asc(t.sortOrder),
          ]))
        .get();
    return rows.map(_toSource).toList();
  }

  @override
  Future<PaymentSource?> getSource(String id) async {
    final PaymentSourceRow? row = await (_db.select(_db.paymentSources)
          ..where(($PaymentSourcesTable t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toSource(row);
  }

  @override
  Future<void> updateSource(PaymentSource source) async {
    await (_db.update(_db.paymentSources)
          ..where(($PaymentSourcesTable t) => t.id.equals(source.id)))
        .write(
      PaymentSourcesCompanion(
        displayName: Value<String>(source.displayName),
        commissionRateBps: Value<int>(source.commissionRateBps),
        defaultTdsRateBps: Value<int>(source.defaultTdsRateBps),
        sortOrder: Value<int>(source.sortOrder),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  // --- Clients -------------------------------------------------------------

  @override
  Stream<List<ClientSummary>> watchClientSummaries({
    bool includeArchived = false,
  }) {
    return _watchLedger(includeArchivedClients: includeArchived)
        .map((List<_LedgerRow> rows) {
      final DateTime now = today();
      final Map<String, Client> clients = <String, Client>{};
      final Map<String, List<Milestone>> byClient = <String, List<Milestone>>{};

      for (final _LedgerRow row in rows) {
        clients[row.client.id] = row.client;
        final Milestone? milestone = row.milestone;
        if (milestone != null) {
          byClient.putIfAbsent(row.client.id, () => <Milestone>[])
              .add(milestone);
        }
      }

      final List<ClientSummary> summaries = clients.values.map((Client client) {
        final List<Milestone> milestones =
            byClient[client.id] ?? const <Milestone>[];
        final List<Milestone> live = milestones
            .where((Milestone m) => !m.isCancelled && !m.isFullyPaid)
            .toList();
        final List<Milestone> overdue =
            live.where((Milestone m) => m.isOverdueAsOf(now)).toList();

        return ClientSummary(
          client: client,
          outstanding:
              MoneyBag.of(live.map((Milestone m) => m.outstanding)),
          overdue: MoneyBag.of(overdue.map((Milestone m) => m.outstanding)),
          openMilestoneCount: live.length,
          overdueMilestoneCount: overdue.length,
          maxDaysOverdue: overdue.fold<int>(
            0,
            (int worst, Milestone m) {
              final int days = m.daysOverdueAsOf(now);
              return days > worst ? days : worst;
            },
          ),
        );
      }).toList();

      // Worst debtors first: most days overdue, then by name so the order is
      // stable for everyone who owes nothing.
      summaries.sort((ClientSummary a, ClientSummary b) {
        final int byOverdue = b.maxDaysOverdue.compareTo(a.maxDaysOverdue);
        if (byOverdue != 0) return byOverdue;
        return a.client.name.toLowerCase().compareTo(
              b.client.name.toLowerCase(),
            );
      });
      return summaries;
    });
  }

  @override
  Stream<Client?> watchClient(String id) {
    return (_db.select(_db.clients)..where(($ClientsTable t) => t.id.equals(id)))
        .watchSingleOrNull()
        .map((ClientRow? row) => row == null ? null : _toClient(row));
  }

  @override
  Future<Client?> getClient(String id) async {
    final ClientRow? row = await (_db.select(_db.clients)
          ..where(($ClientsTable t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toClient(row);
  }

  @override
  Future<String> createClient(ClientDraft draft) async {
    final String id = _uuid.v4();
    final DateTime now = DateTime.now();
    await _db.into(_db.clients).insert(
          ClientsCompanion.insert(
            id: id,
            name: draft.name.trim(),
            company: Value<String?>(_trimToNull(draft.company)),
            email: Value<String?>(_trimToNull(draft.email)),
            phone: Value<String?>(_trimToNull(draft.phone)),
            notes: Value<String?>(_trimToNull(draft.notes)),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  @override
  Future<void> updateClient(String id, ClientDraft draft) async {
    await (_db.update(_db.clients)..where(($ClientsTable t) => t.id.equals(id)))
        .write(
      ClientsCompanion(
        name: Value<String>(draft.name.trim()),
        company: Value<String?>(_trimToNull(draft.company)),
        email: Value<String?>(_trimToNull(draft.email)),
        phone: Value<String?>(_trimToNull(draft.phone)),
        notes: Value<String?>(_trimToNull(draft.notes)),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> setClientArchived(String id, bool archived) async {
    await (_db.update(_db.clients)..where(($ClientsTable t) => t.id.equals(id)))
        .write(
      ClientsCompanion(
        archivedAt: Value<DateTime?>(archived ? DateTime.now() : null),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteClient(String id) async {
    // Projects, milestones and payments go with it via ON DELETE CASCADE.
    await (_db.delete(_db.clients)..where(($ClientsTable t) => t.id.equals(id)))
        .go();
  }

  // --- Projects ------------------------------------------------------------

  @override
  Stream<List<ProjectSummary>> watchProjectSummaries(
    String clientId, {
    bool includeArchived = false,
  }) {
    return _watchLedger(
      clientId: clientId,
      includeArchivedClients: true,
      includeArchivedProjects: includeArchived,
    ).map((List<_LedgerRow> rows) {
      final DateTime now = today();
      final Map<String, Project> projects = <String, Project>{};
      final Map<String, List<Milestone>> byProject =
          <String, List<Milestone>>{};

      for (final _LedgerRow row in rows) {
        final Project? project = row.project;
        if (project == null) continue;
        projects[project.id] = project;
        final Milestone? milestone = row.milestone;
        if (milestone != null) {
          byProject.putIfAbsent(project.id, () => <Milestone>[]).add(milestone);
        }
      }

      final List<ProjectSummary> summaries =
          projects.values.map((Project project) {
        final List<Milestone> milestones =
            byProject[project.id] ?? const <Milestone>[];
        final List<Milestone> counted =
            milestones.where((Milestone m) => !m.isCancelled).toList();

        return ProjectSummary(
          project: project,
          outstanding: MoneyBag.of(
            counted.map((Milestone m) => m.outstanding),
          ),
          billed: MoneyBag.of(counted.map((Milestone m) => m.grossAmount)),
          received: MoneyBag.of(counted.map((Milestone m) => m.amountPaid)),
          milestoneCount: counted.length,
          overdueMilestoneCount:
              counted.where((Milestone m) => m.isOverdueAsOf(now)).length,
        );
      }).toList();

      summaries.sort((ProjectSummary a, ProjectSummary b) {
        // Active projects above archived ones, newest first within each group.
        final int byArchived = (a.project.isArchived ? 1 : 0)
            .compareTo(b.project.isArchived ? 1 : 0);
        if (byArchived != 0) return byArchived;
        return b.project.createdAt.compareTo(a.project.createdAt);
      });
      return summaries;
    });
  }

  @override
  Stream<Project?> watchProject(String id) {
    return (_db.select(_db.projects)
          ..where(($ProjectsTable t) => t.id.equals(id)))
        .watchSingleOrNull()
        .map((ProjectRow? row) => row == null ? null : _toProject(row));
  }

  @override
  Future<Project?> getProject(String id) async {
    final ProjectRow? row = await (_db.select(_db.projects)
          ..where(($ProjectsTable t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toProject(row);
  }

  @override
  Future<String> createProject(ProjectDraft draft) async {
    final String id = _uuid.v4();
    final DateTime now = DateTime.now();
    await _db.into(_db.projects).insert(
          ProjectsCompanion.insert(
            id: id,
            clientId: draft.clientId,
            name: draft.name.trim(),
            description: Value<String?>(_trimToNull(draft.description)),
            defaultSourceId: draft.defaultSourceId,
            defaultCurrency: draft.defaultCurrency,
            externalRef: Value<String?>(_trimToNull(draft.externalRef)),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  @override
  Future<void> updateProject(String id, ProjectDraft draft) async {
    await (_db.update(_db.projects)
          ..where(($ProjectsTable t) => t.id.equals(id)))
        .write(
      ProjectsCompanion(
        name: Value<String>(draft.name.trim()),
        description: Value<String?>(_trimToNull(draft.description)),
        defaultSourceId: Value<String>(draft.defaultSourceId),
        defaultCurrency: Value<String>(draft.defaultCurrency),
        externalRef: Value<String?>(_trimToNull(draft.externalRef)),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> setProjectArchived(String id, bool archived) async {
    await (_db.update(_db.projects)
          ..where(($ProjectsTable t) => t.id.equals(id)))
        .write(
      ProjectsCompanion(
        archivedAt: Value<DateTime?>(archived ? DateTime.now() : null),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteProject(String id) async {
    await (_db.delete(_db.projects)
          ..where(($ProjectsTable t) => t.id.equals(id)))
        .go();
  }

  // --- Milestones ----------------------------------------------------------

  @override
  Stream<List<Milestone>> watchMilestonesForProject(String projectId) {
    return _watchLedger(
      projectId: projectId,
      includeArchivedClients: true,
      includeArchivedProjects: true,
    ).map((List<_LedgerRow> rows) {
      final List<Milestone> milestones = rows
          .map((_LedgerRow row) => row.milestone)
          .whereType<Milestone>()
          .toList();
      _sortForCollection(milestones);
      return milestones;
    });
  }

  @override
  Stream<List<MilestoneWithContext>> watchMilestonesForClient(String clientId) {
    return _watchLedger(
      clientId: clientId,
      includeArchivedClients: true,
      includeArchivedProjects: true,
    ).map(_toContextList);
  }

  @override
  Stream<List<MilestoneWithContext>> watchOpenMilestones() {
    return _watchLedger().map((List<_LedgerRow> rows) {
      final List<_LedgerRow> open = rows.where((_LedgerRow row) {
        final Milestone? milestone = row.milestone;
        return milestone != null &&
            !milestone.isCancelled &&
            !milestone.isFullyPaid;
      }).toList();
      return _toContextList(open);
    });
  }

  List<MilestoneWithContext> _toContextList(List<_LedgerRow> rows) {
    final List<MilestoneWithContext> items = <MilestoneWithContext>[];
    for (final _LedgerRow row in rows) {
      final Milestone? milestone = row.milestone;
      final Project? project = row.project;
      if (milestone == null || project == null) continue;
      items.add(
        MilestoneWithContext(
          milestone: milestone,
          project: project,
          client: row.client,
        ),
      );
    }
    items.sort((MilestoneWithContext a, MilestoneWithContext b) =>
        _compareForCollection(a.milestone, b.milestone));
    return items;
  }

  /// Orders milestones the way someone chasing money reads them: still owed and
  /// most overdue at the top, settled rows at the bottom.
  static int _compareForCollection(Milestone a, Milestone b) {
    int rank(Milestone m) {
      if (m.isCancelled) return 2;
      if (m.isFullyPaid) return 1;
      return 0;
    }

    final int byRank = rank(a).compareTo(rank(b));
    if (byRank != 0) return byRank;
    final int byDue = a.dueDate.compareTo(b.dueDate);
    if (byDue != 0) return byDue;
    return a.createdAt.compareTo(b.createdAt);
  }

  static void _sortForCollection(List<Milestone> milestones) =>
      milestones.sort(_compareForCollection);

  @override
  Stream<Milestone?> watchMilestone(String id) {
    final Expression<int> paidMinor = _db.payments.amountMinor.sum();
    final JoinedSelectStatement<HasResultSet, dynamic> query =
        _db.select(_db.milestones).join(<Join<HasResultSet, dynamic>>[
      leftOuterJoin(
        _db.payments,
        _db.payments.milestoneId.equalsExp(_db.milestones.id),
      ),
    ])
          ..addColumns(<Expression<Object>>[paidMinor])
          ..where(_db.milestones.id.equals(id))
          ..groupBy(<Expression<Object>>[_db.milestones.id]);

    return query.watchSingleOrNull().map((TypedResult? row) {
      if (row == null) return null;
      return _toMilestone(
        row.readTable(_db.milestones),
        row.read(paidMinor) ?? 0,
      );
    });
  }

  @override
  Future<Milestone?> getMilestone(String id) async {
    final MilestoneRow? row = await (_db.select(_db.milestones)
          ..where(($MilestonesTable t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _toMilestone(row, await _paidMinorFor(id));
  }

  @override
  Future<String> createMilestone(MilestoneDraft draft) async {
    final String id = _uuid.v4();
    final DateTime now = DateTime.now();
    await _db.into(_db.milestones).insert(
          MilestonesCompanion.insert(
            id: id,
            projectId: draft.projectId,
            title: draft.title.trim(),
            grossAmountMinor: draft.grossAmount.minorUnits,
            currency: draft.grossAmount.currency,
            dueDate: dateOnly(draft.dueDate),
            sourceId: draft.sourceId,
            commissionRateBps: Value<int>(draft.commissionRateBps),
            tdsRateBps: Value<int>(draft.tdsRateBps),
            stage: draft.stage,
            invoiceRef: Value<String?>(_trimToNull(draft.invoiceRef)),
            invoicedAt: Value<DateTime?>(draft.invoicedAt),
            notes: Value<String?>(_trimToNull(draft.notes)),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  @override
  Future<void> updateMilestone(String id, MilestoneDraft draft) async {
    await _db.transaction(() async {
      await (_db.update(_db.milestones)
            ..where(($MilestonesTable t) => t.id.equals(id)))
          .write(
        MilestonesCompanion(
          title: Value<String>(draft.title.trim()),
          grossAmountMinor: Value<int>(draft.grossAmount.minorUnits),
          currency: Value<String>(draft.grossAmount.currency),
          dueDate: Value<DateTime>(dateOnly(draft.dueDate)),
          sourceId: Value<String>(draft.sourceId),
          commissionRateBps: Value<int>(draft.commissionRateBps),
          tdsRateBps: Value<int>(draft.tdsRateBps),
          stage: Value<MilestoneStage>(draft.stage),
          invoiceRef: Value<String?>(_trimToNull(draft.invoiceRef)),
          invoicedAt: Value<DateTime?>(draft.invoicedAt),
          notes: Value<String?>(_trimToNull(draft.notes)),
          updatedAt: Value<DateTime>(DateTime.now()),
        ),
      );
      // Editing the amount or the rates moves the net figure, which can settle
      // or unsettle the milestone against payments already recorded.
      await _reconcile(id);
    });
  }

  @override
  Future<void> setMilestoneStage(String id, MilestoneStage stage) async {
    final DateTime now = DateTime.now();
    await (_db.update(_db.milestones)
          ..where(($MilestonesTable t) => t.id.equals(id)))
        .write(
      MilestonesCompanion(
        stage: Value<MilestoneStage>(stage),
        // Stamp the invoice date the first time it is marked invoiced, so the
        // reminder engine has a date to count from.
        invoicedAt: stage == MilestoneStage.invoiced
            ? Value<DateTime?>(now)
            : const Value<DateTime?>.absent(),
        updatedAt: Value<DateTime>(now),
      ),
    );
  }

  @override
  Future<void> deleteMilestone(String id) async {
    await (_db.delete(_db.milestones)
          ..where(($MilestonesTable t) => t.id.equals(id)))
        .go();
  }

  // --- Payments ------------------------------------------------------------

  @override
  Stream<List<Payment>> watchPaymentsForMilestone(String milestoneId) {
    return (_db.select(_db.payments)
          ..where(($PaymentsTable t) => t.milestoneId.equals(milestoneId))
          ..orderBy(<OrderClauseGenerator<$PaymentsTable>>[
            ($PaymentsTable t) => OrderingTerm.desc(t.receivedAt),
            ($PaymentsTable t) => OrderingTerm.desc(t.createdAt),
          ]))
        .watch()
        .map((List<PaymentRow> rows) => rows.map(_toPayment).toList());
  }

  @override
  Future<String> addPayment(PaymentDraft draft) async {
    final String id = _uuid.v4();
    await _db.transaction(() async {
      final MilestoneRow? milestone = await (_db.select(_db.milestones)
            ..where(($MilestonesTable t) => t.id.equals(draft.milestoneId)))
          .getSingleOrNull();
      if (milestone == null) {
        throw StateError('Milestone ${draft.milestoneId} no longer exists.');
      }
      if (milestone.currency != draft.amount.currency) {
        // Allowing this would make the received total incomparable with the
        // milestone's net amount, quietly breaking every balance that reads it.
        throw ArgumentError(
          'Payment is in ${draft.amount.currency} but the milestone is billed '
          'in ${milestone.currency}.',
        );
      }
      if (!draft.amount.isPositive) {
        throw ArgumentError('A payment must be greater than zero.');
      }

      await _db.into(_db.payments).insert(
            PaymentsCompanion.insert(
              id: id,
              milestoneId: draft.milestoneId,
              amountMinor: draft.amount.minorUnits,
              currency: draft.amount.currency,
              receivedAt: dateOnly(draft.receivedAt),
              method: draft.method,
              reference: Value<String?>(_trimToNull(draft.reference)),
              externalTxnId: Value<String?>(_trimToNull(draft.externalTxnId)),
              ingestSource: draft.ingestSource,
              note: Value<String?>(_trimToNull(draft.note)),
              createdAt: DateTime.now(),
            ),
          );
      await _reconcile(draft.milestoneId);
    });
    return id;
  }

  @override
  Future<void> deletePayment(String id) async {
    await _db.transaction(() async {
      final PaymentRow? payment = await (_db.select(_db.payments)
            ..where(($PaymentsTable t) => t.id.equals(id)))
          .getSingleOrNull();
      if (payment == null) return;
      await (_db.delete(_db.payments)
            ..where(($PaymentsTable t) => t.id.equals(id)))
          .go();
      // Removing a receipt can reopen a milestone that was fully paid.
      await _reconcile(payment.milestoneId);
    });
  }

  // --- Reporting -----------------------------------------------------------

  @override
  Stream<List<IncomeRow>> watchIncomeRows() {
    // Inner joins throughout: a payment always has a milestone, project and
    // client behind it, and a row missing any of them would be a corrupt
    // ledger rather than something to render as blank.
    final JoinedSelectStatement<HasResultSet, dynamic> query =
        _db.select(_db.payments).join(<Join<HasResultSet, dynamic>>[
      innerJoin(
        _db.milestones,
        _db.milestones.id.equalsExp(_db.payments.milestoneId),
      ),
      innerJoin(
        _db.projects,
        _db.projects.id.equalsExp(_db.milestones.projectId),
      ),
      innerJoin(_db.clients, _db.clients.id.equalsExp(_db.projects.clientId)),
    ])
          ..orderBy(<OrderingTerm>[
            OrderingTerm.asc(_db.payments.receivedAt),
            OrderingTerm.asc(_db.payments.createdAt),
          ]);

    return query.watch().map((List<TypedResult> rows) {
      return rows.map((TypedResult row) {
        final MilestoneRow milestoneRow = row.readTable(_db.milestones);
        return IncomeRow(
          payment: _toPayment(row.readTable(_db.payments)),
          context: MilestoneWithContext(
            // The paid total is irrelevant to an income row — each row is one
            // receipt — so it is left at zero rather than costing a subquery
            // per payment.
            milestone: _toMilestone(milestoneRow, 0),
            project: _toProject(row.readTable(_db.projects)),
            client: _toClient(row.readTable(_db.clients)),
          ),
        );
      }).toList();
    });
  }

  // --- Reconciliation ------------------------------------------------------

  /// Recomputes the cached `paidAt` stamp for one milestone.
  ///
  /// Called after every write that can change either side of the balance —
  /// adding or removing a payment, and editing the amount or rates. Keeping it
  /// in one place is what stops "paid" and "sum of payments" from drifting
  /// apart; callers never set `paidAt` themselves.
  Future<void> _reconcile(String milestoneId) async {
    final MilestoneRow? row = await (_db.select(_db.milestones)
          ..where(($MilestonesTable t) => t.id.equals(milestoneId)))
        .getSingleOrNull();
    if (row == null) return;

    final int paidMinor = await _paidMinorFor(milestoneId);
    final Milestone milestone = _toMilestone(row, paidMinor);

    if (milestone.isFullyPaid && row.paidAt == null) {
      await (_db.update(_db.milestones)
            ..where(($MilestonesTable t) => t.id.equals(milestoneId)))
          .write(
        MilestonesCompanion(
          // Date the milestone actually settled — the last receipt — rather
          // than "now", so a payment backdated during reconciliation reports
          // in the right tax period.
          paidAt: Value<DateTime?>(await _lastReceiptDate(milestoneId)),
          updatedAt: Value<DateTime>(DateTime.now()),
        ),
      );
    } else if (!milestone.isFullyPaid && row.paidAt != null) {
      await (_db.update(_db.milestones)
            ..where(($MilestonesTable t) => t.id.equals(milestoneId)))
          .write(
        MilestonesCompanion(
          paidAt: const Value<DateTime?>(null),
          updatedAt: Value<DateTime>(DateTime.now()),
        ),
      );
    }
  }

  Future<int> _paidMinorFor(String milestoneId) async {
    final Expression<int> total = _db.payments.amountMinor.sum();
    final JoinedSelectStatement<HasResultSet, dynamic> query =
        _db.selectOnly(_db.payments)
          ..addColumns(<Expression<Object>>[total])
          ..where(_db.payments.milestoneId.equals(milestoneId));
    final TypedResult row = await query.getSingle();
    return row.read(total) ?? 0;
  }

  Future<DateTime?> _lastReceiptDate(String milestoneId) async {
    final Expression<DateTime> latest = _db.payments.receivedAt.max();
    final JoinedSelectStatement<HasResultSet, dynamic> query =
        _db.selectOnly(_db.payments)
          ..addColumns(<Expression<Object>>[latest])
          ..where(_db.payments.milestoneId.equals(milestoneId));
    final TypedResult row = await query.getSingle();
    return row.read(latest);
  }

  static String? _trimToNull(String? value) {
    final String? trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
