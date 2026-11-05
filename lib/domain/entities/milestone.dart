import '../calendar.dart';
import '../money.dart';

/// The stored lifecycle stage of a milestone — the part a user actually sets.
///
/// Note what is absent: `overdue`. Overdue is a function of the due date and
/// today, so persisting it would mean every row silently rotting until some
/// background job rewrote it. It is derived on read instead; see
/// [Milestone.statusAsOf].
enum MilestoneStage {
  /// Agreed work, not yet billed.
  pending,

  /// Invoice or platform payment request sent. This is the clock the reminder
  /// engine cares about.
  invoiced,

  /// Written off or cancelled by agreement. Excluded from every total.
  cancelled,
}

/// What the UI and the aging report display.
enum MilestoneStatus {
  pending,
  invoiced,
  overdue,
  partiallyPaid,
  paid,
  cancelled,
}

/// The atomic unit of the ledger: one billable amount with one due date.
///
/// A milestone carries its own source and deduction rates rather than
/// inheriting them from its project, because a single project can legitimately
/// mix channels — a Fiverr order followed by direct bank transfers once the
/// client moves off-platform.
class Milestone {
  const Milestone({
    required this.id,
    required this.projectId,
    required this.title,
    required this.grossAmount,
    required this.dueDate,
    required this.sourceId,
    required this.commissionRateBps,
    required this.tdsRateBps,
    required this.stage,
    required this.amountPaid,
    required this.createdAt,
    required this.updatedAt,
    this.invoiceRef,
    this.invoicedAt,
    this.paidAt,
    this.notes,
  });

  final String id;
  final String projectId;
  final String title;

  /// What the client is billed, before any deduction.
  final Money grossAmount;

  /// Calendar date the money is due; normalised by [dateOnly] on the way in.
  final DateTime dueDate;

  final String sourceId;

  /// Commission rate captured when this milestone was created, in basis points.
  ///
  /// Deliberately a snapshot rather than a live lookup against the source row:
  /// when Fiverr changes its cut, last year's completed work must still
  /// reconcile against what was actually received. The source supplies the
  /// default for new milestones; this field can be overridden per milestone.
  final int commissionRateBps;

  /// TDS rate in basis points, captured the same way and for the same reason.
  final int tdsRateBps;

  final MilestoneStage stage;

  /// Total received against this milestone — the sum of its payment rows.
  ///
  /// Derived data, populated by the repository. It lives on the entity because
  /// nearly every screen needs it, and recomputing per widget would mean one
  /// query per row.
  final Money amountPaid;

  final String? invoiceRef;
  final DateTime? invoicedAt;

  /// When the milestone became fully paid. Null while any balance remains.
  final DateTime? paidAt;

  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get currency => grossAmount.currency;

  /// Platform commission withheld on this milestone.
  Money get commission => grossAmount.percentage(commissionRateBps);

  /// Tax deducted at source on this milestone.
  Money get tds => grossAmount.percentage(tdsRateBps);

  /// What should actually land in the bank: gross less commission less TDS.
  ///
  /// This, not [grossAmount], is what outstanding balances are measured
  /// against — otherwise every completed Fiverr order would look 20% unpaid
  /// forever.
  Money get netAmount => grossAmount - commission - tds;

  /// Still to be received. Never negative; an overpayment reads as zero.
  Money get outstanding => (netAmount - amountPaid).clampToZero();

  bool get isCancelled => stage == MilestoneStage.cancelled;

  /// True once the received total covers the expected net.
  ///
  /// Uses `>=` rather than `==` so a client who rounds up, or a platform fee
  /// that lands a rupee under estimate, still closes the milestone.
  bool get isFullyPaid =>
      !isCancelled && amountPaid.minorUnits >= netAmount.minorUnits;

  bool get isPartiallyPaid =>
      !isCancelled && amountPaid.isPositive && !isFullyPaid;

  /// Whether this milestone still owes money and is past its due date.
  bool isOverdueAsOf(DateTime reference) =>
      !isCancelled && !isFullyPaid && dateOnly(reference).isAfter(dueDate);

  /// Days past due as of [reference]; zero when not yet due or already settled.
  ///
  /// The aging buckets and the reminder rules both read this number, so it is
  /// defined once here rather than recomputed in each module.
  int daysOverdueAsOf(DateTime reference) {
    if (!isOverdueAsOf(reference)) return 0;
    return daysBetween(dueDate, reference);
  }

  /// Days until due as of [reference]; negative once past due.
  int daysUntilDueAsOf(DateTime reference) => daysBetween(reference, dueDate);

  /// The single status to display, resolved against [reference].
  ///
  /// Precedence is deliberate: overdue outranks partially paid, because a
  /// client who has paid half and is 60 days late is a collection problem, not
  /// a progress update.
  MilestoneStatus statusAsOf(DateTime reference) {
    if (isCancelled) return MilestoneStatus.cancelled;
    if (isFullyPaid) return MilestoneStatus.paid;
    if (isOverdueAsOf(reference)) return MilestoneStatus.overdue;
    if (isPartiallyPaid) return MilestoneStatus.partiallyPaid;
    return switch (stage) {
      MilestoneStage.invoiced => MilestoneStatus.invoiced,
      MilestoneStage.pending => MilestoneStatus.pending,
      MilestoneStage.cancelled => MilestoneStatus.cancelled,
    };
  }

  /// Status as of today. Convenience for UI code.
  MilestoneStatus get status => statusAsOf(today());

  /// Days past due as of today. Convenience for UI code.
  int get daysOverdue => daysOverdueAsOf(today());

  Milestone copyWith({
    String? title,
    Money? grossAmount,
    DateTime? dueDate,
    String? sourceId,
    int? commissionRateBps,
    int? tdsRateBps,
    MilestoneStage? stage,
    Money? amountPaid,
    String? invoiceRef,
    bool clearInvoiceRef = false,
    DateTime? invoicedAt,
    bool clearInvoicedAt = false,
    DateTime? paidAt,
    bool clearPaidAt = false,
    String? notes,
    bool clearNotes = false,
    DateTime? updatedAt,
  }) {
    return Milestone(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      grossAmount: grossAmount ?? this.grossAmount,
      dueDate: dueDate ?? this.dueDate,
      sourceId: sourceId ?? this.sourceId,
      commissionRateBps: commissionRateBps ?? this.commissionRateBps,
      tdsRateBps: tdsRateBps ?? this.tdsRateBps,
      stage: stage ?? this.stage,
      amountPaid: amountPaid ?? this.amountPaid,
      invoiceRef: clearInvoiceRef ? null : (invoiceRef ?? this.invoiceRef),
      invoicedAt: clearInvoicedAt ? null : (invoicedAt ?? this.invoicedAt),
      paidAt: clearPaidAt ? null : (paidAt ?? this.paidAt),
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) => other is Milestone && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
