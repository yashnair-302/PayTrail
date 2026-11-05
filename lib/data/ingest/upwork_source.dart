import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_source.dart';
import '../../domain/ingest/payment_event.dart';
import '../../domain/ingest/payment_source_adapter.dart';
import '../../domain/money.dart';
import 'csv_table.dart';

/// Reads Upwork transaction statements, emails and notifications.
///
/// Structurally a twin of [FiverrSource] and deliberately so: the second
/// implementation of [PaymentSourceAdapter] is the one that proves the
/// interface is actually an extension point rather than a shape fitted to a
/// single platform. Everything that differs between the two — column names,
/// sender domains, the wording of a payout notice, whether a fee column exists
/// — is confined to these two files.
class UpworkSource implements PaymentSourceAdapter {
  const UpworkSource();

  @override
  String get sourceId => SourceIds.upwork;

  @override
  String get displayName => 'Upwork';

  /// Upwork's current flat freelancer service fee.
  @override
  int get commissionRateBps => 1000;

  @override
  Set<String> get emailSenderDomains => const <String>{
        'upwork.com',
        'mail.upwork.com',
        'e.upwork.com',
        'notifications.upwork.com',
      };

  @override
  Set<String> get notificationPackages => const <String>{'com.upwork.android'};

  static const List<String> _dateHeaders = <String>['date', 'transaction date'];
  static const List<String> _refHeaders = <String>[
    'ref id',
    'reference id',
    'reference',
    'transaction id',
  ];
  static const List<String> _typeHeaders = <String>['type', 'transaction type'];
  static const List<String> _amountHeaders = <String>[
    'amount in local currency',
    'amount',
  ];
  static const List<String> _currencyHeaders = <String>['currency'];
  static const List<String> _clientHeaders = <String>[
    'client',
    'team',
    'company',
    'account name',
  ];
  static const List<String> _contractHeaders = <String>[
    'contract id',
    'contract',
  ];
  static const List<String> _descriptionHeaders = <String>[
    'description',
    'memo',
  ];

  /// Upwork transaction types that represent money earned.
  ///
  /// Upwork's statement mixes earnings with its own fee lines, withdrawals and
  /// refunds — and its fee lines are negative amounts of the same transaction.
  /// Importing those would double-count the commission that the milestone's
  /// rate already accounts for.
  static const List<String> _earningTypes = <String>[
    'fixed price',
    'hourly',
    'bonus',
    'milestone',
    'payment',
  ];

  /// Types that are explicitly not income, checked before the earnings list so
  /// "Service Fee" never matches on the word "fee" inside a broader phrase.
  static const List<String> _excludedTypes = <String>[
    'service fee',
    'withdrawal',
    'withdraw',
    'refund',
    'refunded',
    'adjustment',
    'membership',
    'connects',
    'processing fee',
  ];

  @override
  IngestResult parseStatement(String csvContent) {
    final CsvTable? table = CsvTable.parse(csvContent);
    if (table == null) {
      return const IngestResult(
        events: <PaymentEvent>[],
        issues: <IngestIssue>[
          IngestIssue(detail: 'The file has no readable header row.'),
        ],
      );
    }

    final int? dateColumn = table.columnFor(_dateHeaders);
    final int? amountColumn = table.columnFor(_amountHeaders);

    if (dateColumn == null || amountColumn == null) {
      return IngestResult(
        events: const <PaymentEvent>[],
        issues: <IngestIssue>[
          IngestIssue(
            detail: 'This does not look like an Upwork transaction export: no '
                'date and amount columns found. Columns present: '
                '${table.headerSummary}',
          ),
        ],
      );
    }

    final int? refColumn = table.columnFor(_refHeaders);
    final int? typeColumn = table.columnFor(_typeHeaders);
    final int? currencyColumn = table.columnFor(_currencyHeaders);
    final int? clientColumn = table.columnFor(_clientHeaders);
    final int? contractColumn = table.columnFor(_contractHeaders);
    final int? descriptionColumn = table.columnFor(_descriptionHeaders);

    final List<PaymentEvent> events = <PaymentEvent>[];
    final List<IngestIssue> issues = <IngestIssue>[];

    for (int i = 0; i < table.rows.length; i++) {
      final List<String> row = table.rows[i];

      final String type = CsvTable.cell(row, typeColumn).toLowerCase();
      if (type.isNotEmpty) {
        if (_excludedTypes.any((String bad) => type.contains(bad))) continue;
        final bool isEarning =
            _earningTypes.any((String good) => type.contains(good));
        if (!isEarning) continue;
      }

      final DateTime? date =
          parseStatementDate(CsvTable.cell(row, dateColumn));
      if (date == null) {
        issues.add(rowIssue(
          i,
          'Could not read the date "${CsvTable.cell(row, dateColumn)}".',
          row,
        ));
        continue;
      }

      // Upwork states the currency in its own column more often than inline.
      final String declared = CsvTable.cell(row, currencyColumn).toUpperCase();
      final String fallback = RegExp(r'^[A-Z]{3}$').hasMatch(declared)
          ? declared
          : 'USD';
      final Money? amount =
          readMoneyCell(row, amountColumn, fallbackCurrency: fallback);

      if (amount == null) {
        issues.add(rowIssue(i, 'Could not read the amount.', row));
        continue;
      }
      // Negative rows are fees and reversals; they are deductions against an
      // earning line, not payments received.
      if (!amount.isPositive) continue;

      final String ref = CsvTable.cell(row, refColumn);
      final String contract = CsvTable.cell(row, contractColumn);

      events.add(
        PaymentEvent(
          sourceId: sourceId,
          channel: IngestSource.statement,
          grossAmount: amount,
          // Upwork's transaction report already states amounts net of its
          // service fee, which is listed as a separate negative row. Reporting
          // this as net avoids deducting the same 10% twice.
          netAmount: amount,
          occurredAt: date,
          externalTxnId: ref.isEmpty ? null : ref,
          clientHint: _nullIfEmpty(CsvTable.cell(row, clientColumn)),
          projectHint: contract.isEmpty ? null : contract,
          description: _nullIfEmpty(CsvTable.cell(row, descriptionColumn)),
          raw: row.join(', '),
        ),
      );
    }

    if (events.isEmpty && issues.isEmpty) {
      issues.add(
        const IngestIssue(
          detail: 'No earnings rows found. This export may only contain fees, '
              'withdrawals or adjustments.',
        ),
      );
    }

    return IngestResult(events: events, issues: issues);
  }

  static final List<RegExp> _emailSubjects = <RegExp>[
    RegExp(r'payment\s+(has\s+)?(been\s+)?(received|processed|cleared)',
        caseSensitive: false),
    RegExp(r'milestone\s+.*(approved|funded|released|paid)',
        caseSensitive: false),
    RegExp(r'you\s*(.{0,3})?ve\s+been\s+paid', caseSensitive: false),
    RegExp(r'funds?\s+(are\s+)?available', caseSensitive: false),
    RegExp(r'your\s+earnings', caseSensitive: false),
  ];

  @override
  PaymentEvent? parseEmail(EmailMessage message) {
    if (!emailSenderDomains.contains(message.senderDomain)) return null;

    final bool relevant = _emailSubjects
        .any((RegExp pattern) => pattern.hasMatch(message.subject));
    if (!relevant) return null;

    final String text = '${message.subject}\n${message.body}';
    final Money? amount = firstAmountIn(text);
    if (amount == null || !amount.isPositive) return null;

    return PaymentEvent(
      sourceId: sourceId,
      channel: IngestSource.email,
      grossAmount: amount,
      netAmount: amount,
      occurredAt: DateTime(
        message.receivedAt.year,
        message.receivedAt.month,
        message.receivedAt.day,
      ),
      externalTxnId: _firstMatch(
        RegExp(r'\b(?:ref(?:erence)?\s*(?:id)?[:\s#]*)([A-Z0-9-]{6,})\b',
            caseSensitive: false),
        text,
      ),
      projectHint: _firstMatch(
        RegExp(r'\bcontract\s*(?:id)?[:\s#]*([0-9]{6,})\b',
            caseSensitive: false),
        text,
      ),
      description: message.subject,
      raw: message.subject,
    );
  }

  static final List<RegExp> _notificationPatterns = <RegExp>[
    RegExp(r'payment\s+(received|processed|cleared)', caseSensitive: false),
    RegExp(r'milestone\s+.*(approved|released|paid)', caseSensitive: false),
    RegExp(r'you\s*(.{0,3})?ve\s+been\s+paid', caseSensitive: false),
    RegExp(r'funds?\s+(are\s+)?available', caseSensitive: false),
  ];

  @override
  PaymentEvent? parseNotification(NotificationData notification) {
    if (!notificationPackages.contains(notification.packageName)) return null;

    final String text = '${notification.title}\n${notification.text}';
    if (!_notificationPatterns.any((RegExp p) => p.hasMatch(text))) return null;

    final Money? amount = firstAmountIn(text);
    if (amount == null || !amount.isPositive) return null;

    return PaymentEvent(
      sourceId: sourceId,
      channel: IngestSource.notification,
      grossAmount: amount,
      netAmount: amount,
      occurredAt: DateTime(
        notification.postedAt.year,
        notification.postedAt.month,
        notification.postedAt.day,
      ),
      description: notification.title,
      raw: text,
    );
  }

  static String? _nullIfEmpty(String value) => value.isEmpty ? null : value;

  static String? _firstMatch(RegExp pattern, String text) =>
      pattern.firstMatch(text)?.group(1);
}
