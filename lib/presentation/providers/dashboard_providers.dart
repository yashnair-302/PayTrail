import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/aging.dart';
import '../../domain/calendar.dart';
import '../../domain/entities/payment_source.dart';
import '../../domain/repositories/ledger_repository.dart';
import 'ledger_providers.dart';

/// The dashboard, recomputed whenever the ledger changes.
///
/// A plain `Provider` combining two streams rather than a third query: the open
/// milestones and the source list are already watched elsewhere, and deriving
/// from them keeps the dashboard incapable of disagreeing with the client list
/// it sits beside. The arithmetic itself lives in `buildDashboard`, which knows
/// nothing about Riverpod.
final Provider<AsyncValue<DashboardSummary>> dashboardProvider =
    Provider<AsyncValue<DashboardSummary>>((Ref ref) {
  final AsyncValue<List<MilestoneWithContext>> open =
      ref.watch(openMilestonesProvider);
  final AsyncValue<List<PaymentSource>> sources =
      ref.watch(paymentSourcesProvider);

  // Surface the first error rather than a spinner that never resolves.
  if (open.hasError) {
    return AsyncValue<DashboardSummary>.error(
      open.error!,
      open.stackTrace ?? StackTrace.current,
    );
  }
  if (sources.hasError) {
    return AsyncValue<DashboardSummary>.error(
      sources.error!,
      sources.stackTrace ?? StackTrace.current,
    );
  }

  final List<MilestoneWithContext>? openValue = open.value;
  final List<PaymentSource>? sourceValue = sources.value;
  if (openValue == null || sourceValue == null) {
    return const AsyncValue<DashboardSummary>.loading();
  }

  return AsyncValue<DashboardSummary>.data(
    buildDashboard(
      open: openValue,
      sources: sourceValue,
      // Resolved once here so every figure on the screen is measured against
      // the same day, even if the widget rebuilds either side of midnight.
      asOf: today(),
    ),
  );
});
