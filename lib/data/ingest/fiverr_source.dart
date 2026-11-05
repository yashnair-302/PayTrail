import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_source.dart';
import '../../domain/ingest/payment_event.dart';
import '../../domain/ingest/payment_source_adapter.dart';
import '../../domain/money.dart';
import 'csv_table.dart';

/// Reads Fiverr earnings statements, emails and notifications.
///
/// Everything Fiverr-specific in the app lives here. The deduplicator, the
/// review queue and the importer never mention Fiverr by name.
class FiverrSource implements PaymentSourceAdapter {
  const FiverrSource();

  @override
  String get sourceId => SourceIds.fiverr;

  @override
  String get displayName => 'Fiverr';

  /// Fiverr's standard seller commission.
  @override
  int get commissionRateBps => 2000;

  @override
  Set<String> get emailSenderDomains => const <String>{
        'fiverr.com',
        'e.fiverr.com',
        'mail.fiverr.com',
      };

  @override
  Set<String> get notificationPackages => const <String>{'com.fiverr.fiverr'};

  /// Header names seen across Fiverr's earnings CSV exports.
  ///
  /// Listed most-specific first so "Net amount" wins over a bare "Amount" when
  /// both are present — the net figure is what actually reaches the bank.
  static const List<String> _dateHeaders = <String>['date', 'created at', 'time'];
  static const List<String> _orderHeaders = <String>[
    'order id',
    'order number',
    'order',
  ];
  static const List<String> _typeHeaders = <String>['type', 'activity'];
  static const List<String> _grossHeaders = <String>[
    'order amount',
    'gross amount',
    'order total',
    'total',
    'amount',
  ];
  static const List<String> _netHeaders = <String>[
    'net amount',
    'net',
    'your earnings',
    'earnings',
  ];
  static const List<String> _feeHeaders = <String>[
    'service fee',
    'fee',
    'commission',
  ];
  static const List<String> _buyerHeaders = <String>[
    'buyer',
    'username',
    'from',
    'client',
  ];
  static const List<String> _currencyHeaders = <String>['currency'];
  static const List<String> _descriptionHeaders = <String>[
    'description',
    'gig',
    'service',
    'item',
    'memo',
  ];

  /// Row types that represent money earned, as opposed to withdrawals,
  /// refunds or balance adjustments.
  ///
  /// Matched loosely because the wording varies by export. Anything not
  /// recognised as earnings is skipped rather than imported, so a withdrawal
  /// never shows up as a client payment.
  static const List<String> _earningTypes = <String>[
    'earning',
    'order completed',
    'completed',
    'cleared',
    'payment',
    'revenue',
    'tip',
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
    final int? grossColumn = table.columnFor(_grossHeaders);
    final int? netColumn = table.columnFor(_netHeaders);

    if (dateColumn == null || (grossColumn == null && netColumn == null)) {
      return IngestResult(
        events: const <PaymentEvent>[],
        issues: <IngestIssue>[
          IngestIssue(
            detail: 'This does not look like a Fiverr earnings export: no '
                'date and amount columns found. Columns present: '
                '${table.headerSummary}',
          ),
        ],
      );
    }

    final int? orderColumn = table.columnFor(_orderHeaders);
    final int? typeColumn = table.columnFor(_typeHeaders);
    final int? feeColumn = table.columnFor(_feeHeaders);
    final int? buyerColumn = table.columnFor(_buyerHeaders);
    final int? currencyColumn = table.columnFor(_currencyHeaders);
    final int? descriptionColumn = table.columnFor(_descriptionHeaders);

    final List<PaymentEvent> events = <PaymentEvent>[];
    final List<IngestIssue> issues = <IngestIssue>[];

    for (int i = 0; i < table.rows.length; i++) {
      final List<String> row = table.rows[i];

      final String type = CsvTable.cell(row, typeColumn).toLowerCase();
      if (typeColumn != null && type.isNotEmpty) {
        final bool isEarning = _earningTypes
            .any((String candidate) => type.contains(candidate));
        if (!isEarning) continue; // Withdrawal, refund, adjustment — not income.
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

      // Fiverr states the currency in its own column; a symbol on the amount
      // (`$`, `₹`) still wins, but a bare "500.00" takes this rather than
      // silently defaulting to USD when the seller settles in another currency.
      final String declared =
          CsvTable.cell(row, currencyColumn).trim().toUpperCase();
      final String rowCurrency =
          RegExp(r'^[A-Z]{3}$').hasMatch(declared) ? declared : 'USD';

      final Money? gross = _readMoney(row, grossColumn, rowCurrency) ??
          _readMoney(row, netColumn, rowCurrency);
      if (gross == null || !gross.isPositive) {
        issues.add(rowIssue(i, 'Could not read a positive amount.', row));
        continue;
      }

      // Prefer the stated net; otherwise derive it from a stated fee; only
      // fall back to the standard rate when the export gives neither.
      Money? net = _readMoney(row, netColumn, rowCurrency);
      if (net == null) {
        final Money? fee = _readMoney(row, feeColumn, rowCurrency);
        if (fee != null) {
          net = gross - Money(fee.minorUnits.abs(), gross.currency);
        }
      }
      if (net != null && net.currency != gross.currency) net = null;

      final String orderId = CsvTable.cell(row, orderColumn);
      events.add(
        PaymentEvent(
          sourceId: sourceId,
          channel: IngestSource.statement,
          grossAmount: gross,
          netAmount: net,
          occurredAt: date,
          externalTxnId: orderId.isEmpty ? null : orderId,
          clientHint: _nullIfEmpty(CsvTable.cell(row, buyerColumn)),
          projectHint: orderId.isEmpty ? null : orderId,
          description: _nullIfEmpty(CsvTable.cell(row, descriptionColumn)),
          raw: row.join(', '),
        ),
      );
    }

    if (events.isEmpty && issues.isEmpty) {
      issues.add(
        const IngestIssue(
          detail: 'No earnings rows found. This export may only contain '
              'withdrawals or balance adjustments.',
        ),
      );
    }

    return IngestResult(events: events, issues: issues);
  }

  /// Subjects Fiverr uses for money-has-moved notices.
  static final List<RegExp> _emailSubjects = <RegExp>[
    RegExp(r'order\s+.*completed', caseSensitive: false),
    RegExp(r'funds?\s+(are\s+)?available', caseSensitive: false),
    RegExp(r'payment\s+(has\s+)?cleared', caseSensitive: false),
    RegExp(r'you\s+(have\s+)?(just\s+)?earned', caseSensitive: false),
  ];

  @override
  PaymentEvent? parseEmail(EmailMessage message) {
    // Checked again here, not only by the caller: a bug in the query filter
    // must not become a parser reading someone's personal mail.
    if (!emailSenderDomains.contains(message.senderDomain)) return null;

    final bool relevant = _emailSubjects
        .any((RegExp pattern) => pattern.hasMatch(message.subject));
    if (!relevant) return null;

    final Money? amount = _firstAmountIn('${message.subject}\n${message.body}');
    if (amount == null || !amount.isPositive) return null;

    final String? orderId = _firstMatch(
      RegExp(r'\b(FO[A-Z0-9]{6,})\b', caseSensitive: false),
      '${message.subject}\n${message.body}',
    );

    return PaymentEvent(
      sourceId: sourceId,
      channel: IngestSource.email,
      grossAmount: amount,
      occurredAt: DateTime(
        message.receivedAt.year,
        message.receivedAt.month,
        message.receivedAt.day,
      ),
      externalTxnId: orderId,
      projectHint: orderId,
      description: message.subject,
      raw: message.subject,
    );
  }

  static final List<RegExp> _notificationPatterns = <RegExp>[
    RegExp(r'order\s+.*(completed|delivered\s+and\s+paid)',
        caseSensitive: false),
    RegExp(r'funds?\s+(are\s+)?available', caseSensitive: false),
    RegExp(r'you\s+(have\s+)?(just\s+)?earned', caseSensitive: false),
    RegExp(r'payment\s+(has\s+)?cleared', caseSensitive: false),
  ];

  @override
  PaymentEvent? parseNotification(NotificationData notification) {
    if (!notificationPackages.contains(notification.packageName)) return null;

    final String text = '${notification.title}\n${notification.text}';
    if (!_notificationPatterns.any((RegExp p) => p.hasMatch(text))) return null;

    final Money? amount = _firstAmountIn(text);
    if (amount == null || !amount.isPositive) return null;

    return PaymentEvent(
      sourceId: sourceId,
      channel: IngestSource.notification,
      grossAmount: amount,
      occurredAt: DateTime(
        notification.postedAt.year,
        notification.postedAt.month,
        notification.postedAt.day,
      ),
      // A notification carries no transaction id, which is why the dedupe key
      // falls back to amount and date.
      description: notification.title,
      raw: text,
    );
  }

  static Money? _readMoney(
    List<String> row,
    int? column, [
    String fallbackCurrency = 'USD',
  ]) =>
      readMoneyCell(row, column, fallbackCurrency: fallbackCurrency);

  static String? _nullIfEmpty(String value) => value.isEmpty ? null : value;

  static String? _firstMatch(RegExp pattern, String text) =>
      pattern.firstMatch(text)?.group(1);

  static Money? _firstAmountIn(String text) => firstAmountIn(text);
}
