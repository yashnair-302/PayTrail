import 'package:csv/csv.dart';

import '../../core/formatting.dart';
import '../../domain/entities/payment.dart';
import '../../domain/export/income_report.dart';
import '../../domain/money.dart';

/// Writes the tax-filing CSV.
///
/// Amounts are written as plain decimal strings with no currency symbol and no
/// thousands separators, in a separate column from the currency code. A
/// spreadsheet reads `1250.50` as a number and `₹1,250.50` as text, and a CA
/// receiving the second one has to clean the file before they can sum it.
class CsvExporter {
  const CsvExporter();

  static const List<String> _headers = <String>[
    'Date received',
    'Client',
    'Project',
    'Milestone',
    'Source',
    'Currency',
    'Amount received',
    'Milestone gross',
    'Commission',
    'TDS',
    'Reference',
    'Recorded via',
  ];

  /// One row per receipt.
  ///
  /// Receipts, not milestones: income is taxable when it is received, and a
  /// milestone settled across three instalments is three entries in the books.
  /// The milestone's gross, commission and TDS repeat across those rows as
  /// context — the header names them as milestone-level figures so nobody sums
  /// the wrong column.
  String buildIncomeCsv(IncomeReport report) {
    final List<List<String>> rows = <List<String>>[
      _headers,
      for (final IncomeRow row in report.rows)
        <String>[
          formatIsoDate(row.receivedAt),
          row.clientName,
          row.projectName,
          row.milestoneTitle,
          row.sourceId,
          row.amountReceived.currency,
          row.amountReceived.toDecimalString(),
          row.milestoneGross.toDecimalString(),
          row.milestoneCommission.toDecimalString(),
          row.milestoneTds.toDecimalString(),
          row.reference ?? '',
          _describeIngest(row.ingestSource),
        ],
    ];

    // A totals row per currency, after a blank separator so it is obviously not
    // data. Summing across currencies is left undone on purpose.
    if (report.totalReceived.isNotEmpty) {
      rows.add(List<String>.filled(_headers.length, ''));
      for (final Money total in report.totalReceived.amounts) {
        rows.add(<String>[
          'TOTAL',
          '',
          '',
          '',
          '',
          total.currency,
          total.toDecimalString(),
          '',
          '',
          '',
          '',
          '',
        ]);
      }
    }

    return Csv(lineDelimiter: '\r\n').encode(rows);
  }

  /// A per-client statement for a date range: what was billed, what arrived,
  /// what is still owed.
  String buildClientStatementCsv({
    required String clientName,
    required IncomeReport report,
  }) {
    final List<List<String>> rows = <List<String>>[
      <String>['Client', clientName],
      <String>[
        'Period',
        '${formatIsoDate(report.from)} to ${formatIsoDate(report.to)}',
      ],
      <String>[],
      <String>[
        'Date received',
        'Project',
        'Milestone',
        'Currency',
        'Amount received',
        'Reference',
      ],
      for (final IncomeRow row in report.rows)
        <String>[
          formatIsoDate(row.receivedAt),
          row.projectName,
          row.milestoneTitle,
          row.amountReceived.currency,
          row.amountReceived.toDecimalString(),
          row.reference ?? '',
        ],
      <String>[],
      for (final Money total in report.totalReceived.amounts)
        <String>[
          'TOTAL RECEIVED',
          '',
          '',
          total.currency,
          total.toDecimalString(),
          '',
        ],
    ];

    return Csv(lineDelimiter: '\r\n').encode(rows);
  }

  static String _describeIngest(IngestSource source) => switch (source) {
        IngestSource.manual => 'Manual',
        IngestSource.statement => 'Statement upload',
        IngestSource.email => 'Email',
        IngestSource.notification => 'Notification',
      };
}
