import 'package:intl/intl.dart';

import '../domain/entities/milestone.dart';
import '../domain/entities/payment.dart';
import '../domain/money.dart';
import '../domain/money_bag.dart';

/// Display formatting.
///
/// Kept out of the domain layer on purpose: [Money] knows how to be exact,
/// this knows how to be readable, and only this half depends on locale data.
/// Formatting goes through `double` — acceptable here because the value is
/// about to become pixels, never a number anything else computes on.

final Map<String, NumberFormat> _currencyFormats = <String, NumberFormat>{};

NumberFormat _formatFor(String currency) {
  return _currencyFormats.putIfAbsent(
    currency,
    () => NumberFormat.simpleCurrency(
      name: currency,
      decimalDigits: decimalsForCurrency(currency),
    ),
  );
}

/// `₹1,250.50`, `$400.00`.
String formatMoney(Money amount) {
  final double value =
      amount.minorUnits / _pow10(decimalsForCurrency(amount.currency));
  return _formatFor(amount.currency).format(value);
}

/// `₹1,250.50 + $400.00`, or `—` when there is nothing to show.
///
/// Deliberately never collapses currencies into one figure; see [MoneyBag].
String formatMoneyBag(MoneyBag bag, {String emptyLabel = '—'}) {
  if (bag.isEmpty) return emptyLabel;
  return bag.amounts.map(formatMoney).join('  +  ');
}

/// `24 Sep 2026`.
String formatDate(DateTime date) => DateFormat('d MMM yyyy').format(date);

/// `2026-09-24` — sortable, unambiguous, and what a spreadsheet parses as a
/// date whatever the machine's locale. Used for every exported file.
String formatIsoDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

/// `24 Sep`, for dense rows where the year is obvious.
String formatShortDate(DateTime date) => DateFormat('d MMM').format(date);

/// A basis-point rate as a percentage: 2000 becomes `20%`, 1250 becomes
/// `12.5%`.
String formatRate(int basisPoints) {
  if (basisPoints % 100 == 0) return '${basisPoints ~/ 100}%';
  final double percent = basisPoints / 100;
  return '${percent.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')}%';
}

/// Plain-language due wording: `Due in 5 days`, `12 days overdue`, `Due today`.
String describeDue(Milestone milestone, DateTime reference) {
  if (milestone.isCancelled) return 'Cancelled';
  if (milestone.isFullyPaid) {
    final DateTime? paidAt = milestone.paidAt;
    return paidAt == null ? 'Paid' : 'Paid ${formatDate(paidAt)}';
  }

  final int overdue = milestone.daysOverdueAsOf(reference);
  if (overdue > 0) {
    return overdue == 1 ? '1 day overdue' : '$overdue days overdue';
  }

  final int until = milestone.daysUntilDueAsOf(reference);
  if (until == 0) return 'Due today';
  if (until == 1) return 'Due tomorrow';
  if (until <= 30) return 'Due in $until days';
  return 'Due ${formatDate(milestone.dueDate)}';
}

String describeStatus(MilestoneStatus status) => switch (status) {
      MilestoneStatus.pending => 'Pending',
      MilestoneStatus.invoiced => 'Invoiced',
      MilestoneStatus.overdue => 'Overdue',
      MilestoneStatus.partiallyPaid => 'Part paid',
      MilestoneStatus.paid => 'Paid',
      MilestoneStatus.cancelled => 'Cancelled',
    };

String describeStage(MilestoneStage stage) => switch (stage) {
      MilestoneStage.pending => 'Not yet invoiced',
      MilestoneStage.invoiced => 'Invoiced',
      MilestoneStage.cancelled => 'Cancelled',
    };

String describePaymentMethod(PaymentMethod method) => switch (method) {
      PaymentMethod.platform => 'Platform payout',
      PaymentMethod.bankTransfer => 'Bank transfer',
      PaymentMethod.upi => 'UPI',
      PaymentMethod.cheque => 'Cheque',
      PaymentMethod.cash => 'Cash',
      PaymentMethod.other => 'Other',
    };

String describeIngestSource(IngestSource source) => switch (source) {
      IngestSource.manual => 'Entered manually',
      IngestSource.statement => 'From statement upload',
      IngestSource.email => 'From platform email',
      IngestSource.notification => 'From app notification',
    };

int _pow10(int exponent) {
  int result = 1;
  for (int i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}
