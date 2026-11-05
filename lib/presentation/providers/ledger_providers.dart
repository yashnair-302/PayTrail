import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/client.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_source.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/ledger_repository.dart';

/// The ledger, injected at startup.
///
/// Declared here as a throwing stub and overridden in `main()` with the
/// repository built over the opened, decrypted database. Opening that database
/// is asynchronous and can fail (no keystore entry, SQLCipher missing), so it
/// happens once before `runApp` rather than inside a provider every screen
/// would then have to handle a loading state for.
final Provider<LedgerRepository> ledgerRepositoryProvider =
    Provider<LedgerRepository>(
  (Ref ref) => throw UnimplementedError(
    'ledgerRepositoryProvider must be overridden in main().',
  ),
);

/// Payment channels and their configured rates.
///
/// Not auto-disposed: it is small, read by most forms, and changes rarely.
final StreamProvider<List<PaymentSource>> paymentSourcesProvider =
    StreamProvider<List<PaymentSource>>(
  (Ref ref) => ref.watch(ledgerRepositoryProvider).watchSources(),
);

/// Every client with its outstanding and overdue totals — the home screen.
final StreamProvider<List<ClientSummary>> clientSummariesProvider =
    StreamProvider<List<ClientSummary>>(
  (Ref ref) => ref.watch(ledgerRepositoryProvider).watchClientSummaries(),
);

/// Clients including archived ones, for the archive view.
final StreamProvider<List<ClientSummary>> archivedClientSummariesProvider =
    StreamProvider<List<ClientSummary>>(
  (Ref ref) => ref
      .watch(ledgerRepositoryProvider)
      .watchClientSummaries(includeArchived: true),
);

final clientProvider = StreamProvider.family<Client?, String>(
  (Ref ref, String id) => ref.watch(ledgerRepositoryProvider).watchClient(id),
);

final projectSummariesProvider =
    StreamProvider.family<List<ProjectSummary>, String>(
  (Ref ref, String clientId) =>
      ref.watch(ledgerRepositoryProvider).watchProjectSummaries(clientId),
);

final projectProvider = StreamProvider.family<Project?, String>(
  (Ref ref, String id) => ref.watch(ledgerRepositoryProvider).watchProject(id),
);

final projectMilestonesProvider =
    StreamProvider.family<List<Milestone>, String>(
  (Ref ref, String projectId) =>
      ref.watch(ledgerRepositoryProvider).watchMilestonesForProject(projectId),
);

/// Every milestone belonging to one client, across its projects.
final clientMilestonesProvider =
    StreamProvider.family<List<MilestoneWithContext>, String>(
  (Ref ref, String clientId) =>
      ref.watch(ledgerRepositoryProvider).watchMilestonesForClient(clientId),
);

/// Unsettled work across all clients. Module 2's dashboard and Module 4's
/// reminder queue both build on this.
final StreamProvider<List<MilestoneWithContext>> openMilestonesProvider =
    StreamProvider<List<MilestoneWithContext>>(
  (Ref ref) => ref.watch(ledgerRepositoryProvider).watchOpenMilestones(),
);

final milestoneProvider = StreamProvider.family<Milestone?, String>(
  (Ref ref, String id) =>
      ref.watch(ledgerRepositoryProvider).watchMilestone(id),
);

final milestonePaymentsProvider =
    StreamProvider.family<List<Payment>, String>(
  (Ref ref, String milestoneId) => ref
      .watch(ledgerRepositoryProvider)
      .watchPaymentsForMilestone(milestoneId),
);
