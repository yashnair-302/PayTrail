import '../entities/payment.dart';
import '../money.dart';
import '../money_bag.dart';
import '../repositories/ledger_repository.dart';

/// The shapes Module 5 exports: one row per receipt, and per-client statements.
///
/// Built here as plain data so the CSV writer and the PDF renderer consume the
/// same rows. Two renderers reading two different queries is how an invoice
/// ends up disagreeing with the tax export.

/// One received payment, flattened with everything the tax return needs.
class IncomeRow {
  const IncomeRow({
    required this.payment,
    required this.context,
  });

  final Payment payment;
  final MilestoneWithContext context;

  String get clientName => context.client.name;
  String get projectName => context.project.name;
  String get milestoneTitle => context.milestone.title;
  String get sourceId => context.milestone.sourceId;
  DateTime get receivedAt => payment.receivedAt;
  Money get amountReceived => payment.amount;

  /// The milestone's gross, for context — not a per-payment figure.
  ///
  /// A milestone settled in three instalments has one gross and three rows, so
  /// summing this column would overstate income threefold. The CSV labels it
  /// accordingly and the totals are computed from [amountReceived] alone.
  Money get milestoneGross => context.milestone.grossAmount;

  Money get milestoneCommission => context.milestone.commission;
  Money get milestoneTds => context.milestone.tds;
  String? get reference => payment.reference ?? payment.externalTxnId;
  IngestSource get ingestSource => payment.ingestSource;
}

/// A date-bounded set of receipts, with its totals.
class IncomeReport {
  const IncomeReport({
    required this.rows,
    required this.from,
    required this.to,
    required this.totalReceived,
    required this.byCurrencyCount,
  });

  factory IncomeReport.build({
    required List<IncomeRow> rows,
    required DateTime from,
    required DateTime to,
  }) {
    final List<IncomeRow> inRange = rows
        .where((IncomeRow row) =>
            !row.receivedAt.isBefore(from) && !row.receivedAt.isAfter(to))
        .toList()
      ..sort((IncomeRow a, IncomeRow b) => a.receivedAt.compareTo(b.receivedAt));

    final Map<String, int> counts = <String, int>{};
    for (final IncomeRow row in inRange) {
      final String currency = row.amountReceived.currency;
      counts[currency] = (counts[currency] ?? 0) + 1;
    }

    return IncomeReport(
      rows: inRange,
      from: from,
      to: to,
      totalReceived:
          MoneyBag.of(inRange.map((IncomeRow row) => row.amountReceived)),
      byCurrencyCount: counts,
    );
  }

  final List<IncomeRow> rows;
  final DateTime from;
  final DateTime to;
  final MoneyBag totalReceived;
  final Map<String, int> byCurrencyCount;

  bool get isEmpty => rows.isEmpty;

  /// Receipts grouped by payment channel, for the summary block.
  Map<String, MoneyBag> get bySource {
    final Map<String, List<Money>> grouped = <String, List<Money>>{};
    for (final IncomeRow row in rows) {
      grouped.putIfAbsent(row.sourceId, () => <Money>[]).add(row.amountReceived);
    }
    return <String, MoneyBag>{
      for (final MapEntry<String, List<Money>> entry in grouped.entries)
        entry.key: MoneyBag.of(entry.value),
    };
  }

  /// Receipts grouped by client.
  Map<String, MoneyBag> get byClient {
    final Map<String, List<Money>> grouped = <String, List<Money>>{};
    for (final IncomeRow row in rows) {
      grouped.putIfAbsent(row.clientName, () => <Money>[]).add(row.amountReceived);
    }
    return <String, MoneyBag>{
      for (final MapEntry<String, List<Money>> entry in grouped.entries)
        entry.key: MoneyBag.of(entry.value),
    };
  }
}

/// One line on an invoice.
class InvoiceLine {
  const InvoiceLine({
    required this.description,
    required this.amount,
    this.dueDate,
    this.reference,
  });

  final String description;
  final Money amount;
  final DateTime? dueDate;
  final String? reference;
}

/// Everything a generated invoice needs.
///
/// Assembled in the domain layer so the PDF renderer has no decisions left to
/// make: it lays out what it is given.
class InvoiceDocument {
  const InvoiceDocument({
    required this.number,
    required this.issuedOn,
    required this.dueOn,
    required this.businessName,
    required this.clientName,
    required this.lines,
    required this.subtotal,
    required this.total,
    this.businessAddress,
    this.businessEmail,
    this.businessPhone,
    this.businessTaxId,
    this.clientCompany,
    this.clientEmail,
    this.clientAddress,
    this.tdsAmount,
    this.notes,
  });

  /// Builds an invoice for [milestones], which must share a currency.
  ///
  /// Throws rather than silently dropping the odd one out: an invoice that
  /// quietly omits a line is worse than one that fails to generate.
  factory InvoiceDocument.fromMilestones({
    required String number,
    required DateTime issuedOn,
    required DateTime dueOn,
    required String businessName,
    required String clientName,
    required List<MilestoneWithContext> milestones,
    String? businessAddress,
    String? businessEmail,
    String? businessPhone,
    String? businessTaxId,
    String? clientCompany,
    String? clientEmail,
    String? clientAddress,
    String? notes,
  }) {
    if (milestones.isEmpty) {
      throw ArgumentError('An invoice needs at least one milestone.');
    }
    final String currency = milestones.first.milestone.currency;
    for (final MilestoneWithContext item in milestones) {
      if (item.milestone.currency != currency) {
        throw ArgumentError(
          'All milestones on one invoice must share a currency; found '
          '$currency and ${item.milestone.currency}.',
        );
      }
    }

    final List<InvoiceLine> lines = <InvoiceLine>[
      for (final MilestoneWithContext item in milestones)
        InvoiceLine(
          description: '${item.project.name} — ${item.milestone.title}',
          amount: item.milestone.grossAmount,
          dueDate: item.milestone.dueDate,
          reference: item.milestone.invoiceRef,
        ),
    ];

    // Invoices bill the client the gross amount. Platform commission is a cost
    // between the freelancer and the marketplace and has no place on a document
    // the client reads; TDS does, because the client is the one withholding it.
    final Money subtotal = sumMoney(
      lines.map((InvoiceLine line) => line.amount),
      currency,
    );
    final Money tds = sumMoney(
      milestones.map((MilestoneWithContext m) => m.milestone.tds),
      currency,
    );

    return InvoiceDocument(
      number: number,
      issuedOn: issuedOn,
      dueOn: dueOn,
      businessName: businessName,
      businessAddress: businessAddress,
      businessEmail: businessEmail,
      businessPhone: businessPhone,
      businessTaxId: businessTaxId,
      clientName: clientName,
      clientCompany: clientCompany,
      clientEmail: clientEmail,
      clientAddress: clientAddress,
      lines: lines,
      subtotal: subtotal,
      tdsAmount: tds.isZero ? null : tds,
      total: subtotal,
      notes: notes,
    );
  }

  final String number;
  final DateTime issuedOn;
  final DateTime dueOn;

  final String businessName;
  final String? businessAddress;
  final String? businessEmail;
  final String? businessPhone;
  final String? businessTaxId;

  final String clientName;
  final String? clientCompany;
  final String? clientEmail;
  final String? clientAddress;

  final List<InvoiceLine> lines;
  final Money subtotal;

  /// Shown as a note of what the client will withhold, not deducted from
  /// [total] — the invoice is raised for the full amount and TDS is the
  /// client's statutory deduction against it.
  final Money? tdsAmount;

  final Money total;
  final String? notes;

  String get currency => total.currency;
}

/// Builds an invoice number like `INV-2026-0007`.
///
/// Sequential within a calendar year, which is what Indian bookkeeping expects;
/// [sequence] is the count of invoices already raised this year.
String buildInvoiceNumber({
  required int sequence,
  required DateTime issuedOn,
  String prefix = 'INV',
}) {
  final String padded = (sequence + 1).toString().padLeft(4, '0');
  return '$prefix-${issuedOn.year}-$padded';
}
