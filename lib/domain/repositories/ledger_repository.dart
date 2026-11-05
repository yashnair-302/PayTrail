import '../entities/client.dart';
import '../entities/milestone.dart';
import '../entities/payment.dart';
import '../entities/payment_source.dart';
import '../entities/project.dart';
import '../export/income_report.dart';
import '../money.dart';
import '../money_bag.dart';

/// A client together with the totals the list screen shows.
///
/// Bundled into one type so the list can be rendered from a single query
/// instead of N+1 lookups per row.
class ClientSummary {
  const ClientSummary({
    required this.client,
    required this.outstanding,
    required this.overdue,
    required this.openMilestoneCount,
    required this.overdueMilestoneCount,
    required this.maxDaysOverdue,
  });

  final Client client;

  /// Net still to be received across this client's live milestones.
  final MoneyBag outstanding;

  /// The part of [outstanding] that is already past its due date.
  final MoneyBag overdue;

  final int openMilestoneCount;
  final int overdueMilestoneCount;

  /// Days overdue of this client's oldest unpaid milestone; zero if none are.
  /// Drives the sort order on the client list — worst offenders first.
  final int maxDaysOverdue;

  bool get hasOverdue => overdueMilestoneCount > 0;
}

/// A project together with its rolled-up milestone totals.
class ProjectSummary {
  const ProjectSummary({
    required this.project,
    required this.outstanding,
    required this.billed,
    required this.received,
    required this.milestoneCount,
    required this.overdueMilestoneCount,
  });

  final Project project;

  /// Net still to be received.
  final MoneyBag outstanding;

  /// Gross billed across all non-cancelled milestones.
  final MoneyBag billed;

  /// Net actually received.
  final MoneyBag received;

  final int milestoneCount;
  final int overdueMilestoneCount;
}

/// A milestone with the context a list row needs to be readable on its own.
class MilestoneWithContext {
  const MilestoneWithContext({
    required this.milestone,
    required this.project,
    required this.client,
  });

  final Milestone milestone;
  final Project project;
  final Client client;
}

/// Fields required to create or replace a client.
class ClientDraft {
  const ClientDraft({
    required this.name,
    this.company,
    this.email,
    this.phone,
    this.notes,
  });

  final String name;
  final String? company;
  final String? email;
  final String? phone;
  final String? notes;
}

/// Fields required to create or replace a project.
class ProjectDraft {
  const ProjectDraft({
    required this.clientId,
    required this.name,
    required this.defaultSourceId,
    required this.defaultCurrency,
    this.description,
    this.externalRef,
  });

  final String clientId;
  final String name;
  final String defaultSourceId;
  final String defaultCurrency;
  final String? description;
  final String? externalRef;
}

/// Fields required to create or replace a milestone.
class MilestoneDraft {
  const MilestoneDraft({
    required this.projectId,
    required this.title,
    required this.grossAmount,
    required this.dueDate,
    required this.sourceId,
    required this.commissionRateBps,
    required this.tdsRateBps,
    required this.stage,
    this.invoiceRef,
    this.invoicedAt,
    this.notes,
  });

  final String projectId;
  final String title;
  final Money grossAmount;
  final DateTime dueDate;
  final String sourceId;
  final int commissionRateBps;
  final int tdsRateBps;
  final MilestoneStage stage;
  final String? invoiceRef;
  final DateTime? invoicedAt;
  final String? notes;
}

/// Fields required to record a receipt.
class PaymentDraft {
  const PaymentDraft({
    required this.milestoneId,
    required this.amount,
    required this.receivedAt,
    required this.method,
    this.reference,
    this.externalTxnId,
    this.ingestSource = IngestSource.manual,
    this.note,
  });

  final String milestoneId;
  final Money amount;
  final DateTime receivedAt;
  final PaymentMethod method;
  final String? reference;
  final String? externalTxnId;
  final IngestSource ingestSource;
  final String? note;
}

/// The ledger's read and write surface.
///
/// Declared in the domain layer and implemented over Drift in the data layer,
/// so the aging calculator, the reminder rules and their tests depend on this
/// interface rather than on SQLite. Reads are `Stream`s because the whole UI is
/// reactive: recording a payment updates the milestone row, the project total
/// and the client list without any screen having to know to refresh.
abstract interface class LedgerRepository {
  // --- Sources -------------------------------------------------------------

  Stream<List<PaymentSource>> watchSources();
  Future<List<PaymentSource>> getSources();
  Future<PaymentSource?> getSource(String id);
  Future<void> updateSource(PaymentSource source);

  // --- Clients -------------------------------------------------------------

  /// Clients with their totals, worst overdue first.
  Stream<List<ClientSummary>> watchClientSummaries({
    bool includeArchived = false,
  });

  Stream<Client?> watchClient(String id);
  Future<Client?> getClient(String id);
  Future<String> createClient(ClientDraft draft);
  Future<void> updateClient(String id, ClientDraft draft);
  Future<void> setClientArchived(String id, bool archived);

  /// Permanently removes a client and everything under it.
  ///
  /// Archiving is the normal path; this exists for genuine mistakes, and the
  /// UI confirms with a count of what will go.
  Future<void> deleteClient(String id);

  // --- Projects ------------------------------------------------------------

  Stream<List<ProjectSummary>> watchProjectSummaries(
    String clientId, {
    bool includeArchived = false,
  });

  Stream<Project?> watchProject(String id);
  Future<Project?> getProject(String id);
  Future<String> createProject(ProjectDraft draft);
  Future<void> updateProject(String id, ProjectDraft draft);
  Future<void> setProjectArchived(String id, bool archived);
  Future<void> deleteProject(String id);

  // --- Milestones ----------------------------------------------------------

  Stream<List<Milestone>> watchMilestonesForProject(String projectId);
  Stream<List<MilestoneWithContext>> watchMilestonesForClient(String clientId);

  /// Every milestone that still owes money, across all clients.
  /// The dashboard and the reminder engine both read this.
  Stream<List<MilestoneWithContext>> watchOpenMilestones();

  Stream<Milestone?> watchMilestone(String id);
  Future<Milestone?> getMilestone(String id);
  Future<String> createMilestone(MilestoneDraft draft);
  Future<void> updateMilestone(String id, MilestoneDraft draft);
  Future<void> setMilestoneStage(String id, MilestoneStage stage);
  Future<void> deleteMilestone(String id);

  // --- Payments ------------------------------------------------------------

  Stream<List<Payment>> watchPaymentsForMilestone(String milestoneId);

  /// Records a receipt and reconciles the milestone in one transaction.
  ///
  /// Returns the payment id. The milestone's `paidAt` is set or cleared here
  /// rather than by the caller, so a part payment followed by the balance
  /// always lands in a consistent state.
  Future<String> addPayment(PaymentDraft draft);

  Future<void> deletePayment(String id);

  // --- Reporting -----------------------------------------------------------

  /// Every receipt in the ledger, each with its milestone, project and client.
  ///
  /// The single read behind Module 5: the tax CSV, the client statement and the
  /// invoice totals are all filtered views of this one list, so they cannot
  /// disagree with each other.
  Stream<List<IncomeRow>> watchIncomeRows();
}
