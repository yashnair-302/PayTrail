import 'package:csv/csv.dart';

import '../../domain/ingest/payment_event.dart';
import '../../domain/money.dart';

/// A parsed CSV with its header row resolved to column indices.
///
/// Marketplace statement exports are not a stable contract: column order
/// changes between releases, headers get renamed ("Amount" becomes "Amount
/// (USD)"), and locales add or drop columns. Addressing columns by fuzzy header
/// name rather than by position means a reordered export keeps working and a
/// genuinely missing column produces a clear message instead of silently
/// reading the wrong field.
class CsvTable {
  CsvTable._(this._headers, this.rows);

  /// Parses [content], treating the first non-empty row as the header.
  ///
  /// Returns null when the file has no usable header row.
  static CsvTable? parse(String content) {
    // dynamicTyping off: every cell stays a string. Letting the decoder coerce
    // would turn an order id like "0012" into 12 and an amount into a double,
    // which is exactly the precision loss the ledger avoids everywhere else.
    final List<List<dynamic>> raw = Csv(dynamicTyping: false).decode(content);

    final List<List<String>> cleaned = raw
        .map((List<dynamic> row) =>
            row.map((dynamic cell) => '${cell ?? ''}'.trim()).toList())
        .where((List<String> row) =>
            row.any((String cell) => cell.isNotEmpty))
        .toList();

    if (cleaned.isEmpty) return null;

    final List<String> headers = cleaned.first
        .map((String header) => _normalise(header))
        .toList();
    if (headers.every((String header) => header.isEmpty)) return null;

    return CsvTable._(headers, cleaned.skip(1).toList());
  }

  final List<String> _headers;

  /// Data rows, header excluded.
  final List<List<String>> rows;

  /// Index of the first header containing any of [candidates], or null.
  ///
  /// Substring matching on a normalised header, so "Amount (USD)", "amount" and
  /// "Gross Amount" all resolve for the candidate `amount`.
  int? columnFor(List<String> candidates) {
    for (final String candidate in candidates) {
      final String needle = _normalise(candidate);
      final int exact = _headers.indexOf(needle);
      if (exact >= 0) return exact;
    }
    for (final String candidate in candidates) {
      final String needle = _normalise(candidate);
      for (int i = 0; i < _headers.length; i++) {
        if (_headers[i].contains(needle)) return i;
      }
    }
    return null;
  }

  /// The cell at [index] in [row], or empty string when out of range.
  static String cell(List<String> row, int? index) {
    if (index == null || index < 0 || index >= row.length) return '';
    return row[index].trim();
  }

  /// A description of the headers actually found, for error messages.
  String get headerSummary => _headers.where((String h) => h.isNotEmpty).join(', ');

  /// Lowercased, punctuation- and space-free, for tolerant comparison.
  static String _normalise(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

/// Reads an amount cell that may carry a currency symbol, sign, or thousands
/// separators.
///
/// Returns null rather than zero for unparseable input: a row whose amount
/// cannot be read must be reported as an issue, never imported as a zero-value
/// payment.
({String? currency, String digits})? splitAmountCell(String cell) {
  String value = cell.trim();
  if (value.isEmpty) return null;

  // Accounting-style negatives: (1,234.00) means -1234.00.
  bool negative = false;
  if (value.startsWith('(') && value.endsWith(')')) {
    negative = true;
    value = value.substring(1, value.length - 1);
  }
  if (value.startsWith('-')) {
    negative = true;
    value = value.substring(1);
  }
  if (value.startsWith('+')) value = value.substring(1);

  // A trailing or leading ISO code, e.g. "1,200.00 USD" or "USD 1,200.00".
  String? currency;
  final RegExpMatch? code =
      RegExp(r'\b([A-Z]{3})\b').firstMatch(value.toUpperCase());
  if (code != null) {
    currency = code.group(1);
    value = value.replaceAll(RegExp(code.group(1)!, caseSensitive: false), '');
  }

  const Map<String, String> symbols = <String, String>{
    r'$': 'USD',
    '₹': 'INR',
    '€': 'EUR',
    '£': 'GBP',
  };
  for (final MapEntry<String, String> entry in symbols.entries) {
    if (value.contains(entry.key)) {
      currency ??= entry.value;
      value = value.replaceAll(entry.key, '');
    }
  }

  value = value.replaceAll(RegExp(r'[\s,]'), '');
  if (value.isEmpty || !RegExp(r'^\d*\.?\d*$').hasMatch(value)) return null;
  if (value == '.' || value.isEmpty) return null;

  return (currency: currency, digits: negative ? '-$value' : value);
}

/// Parses the date formats statement exports actually use.
///
/// Tries ISO first (unambiguous), then the day-first and month-first textual
/// forms. Ambiguous all-numeric dates like `03/04/2026` are read day-first,
/// matching the Indian convention this app is built for; the choice is recorded
/// here rather than left to a locale that may differ on the user's device.
DateTime? parseStatementDate(String value) {
  final String text = value.trim();
  if (text.isEmpty) return null;

  final DateTime? iso = DateTime.tryParse(text);
  if (iso != null) return DateTime(iso.year, iso.month, iso.day);

  const Map<String, int> months = <String, int>{
    'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
    'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
  };

  // "12 Mar 2026", "Mar 12, 2026", "12-Mar-2026"
  final RegExpMatch? textual = RegExp(
    r'^(\d{1,2})[\s\-/]*([A-Za-z]{3,})[\s\-/,]*(\d{4})$',
  ).firstMatch(text);
  if (textual != null) {
    final int? month = months[textual.group(2)!.toLowerCase().substring(0, 3)];
    if (month != null) {
      return DateTime(
        int.parse(textual.group(3)!),
        month,
        int.parse(textual.group(1)!),
      );
    }
  }
  final RegExpMatch? monthFirst = RegExp(
    r'^([A-Za-z]{3,})[\s\-/]*(\d{1,2})[\s\-/,]*(\d{4})$',
  ).firstMatch(text);
  if (monthFirst != null) {
    final int? month =
        months[monthFirst.group(1)!.toLowerCase().substring(0, 3)];
    if (month != null) {
      return DateTime(
        int.parse(monthFirst.group(3)!),
        month,
        int.parse(monthFirst.group(2)!),
      );
    }
  }

  // Numeric d/m/y or d-m-y.
  final RegExpMatch? numeric =
      RegExp(r'^(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{2,4})$').firstMatch(text);
  if (numeric != null) {
    int year = int.parse(numeric.group(3)!);
    if (year < 100) year += 2000;
    final int day = int.parse(numeric.group(1)!);
    final int month = int.parse(numeric.group(2)!);
    if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
      return DateTime(year, month, day);
    }
  }

  return null;
}

/// Reads one amount cell as [Money], or null when it cannot be read.
///
/// [fallbackCurrency] applies only when the cell itself names no currency —
/// marketplace exports often state the currency once in a separate column or
/// only in the file name.
Money? readMoneyCell(
  List<String> row,
  int? column, {
  required String fallbackCurrency,
}) {
  if (column == null) return null;
  final ({String? currency, String digits})? parts =
      splitAmountCell(CsvTable.cell(row, column));
  if (parts == null) return null;
  return Money.tryParse(parts.digits, parts.currency ?? fallbackCurrency);
}

const Map<String, String> _currencyTokens = <String, String>{
  r'$': 'USD',
  r'us$': 'USD',
  'usd': 'USD',
  '₹': 'INR',
  'rs': 'INR',
  'inr': 'INR',
  '€': 'EUR',
  'eur': 'EUR',
  '£': 'GBP',
  'gbp': 'GBP',
};

/// The first currency amount in free text — `$120.00`, `USD 120`, `₹4,500`.
///
/// Used by the email and notification parsers, where there is no column to read
/// and the figure has to be found in a sentence. Returns null rather than
/// guessing when no amount is present, so a "your order was delivered" notice
/// with no money in it never becomes a payment.
Money? firstAmountIn(String text, {String fallbackCurrency = 'USD'}) {
  final RegExpMatch? match = RegExp(
    r'(?:(US\$|\$|₹|€|£|USD|INR|EUR|GBP|Rs\.?)\s*)([0-9][0-9,]*(?:\.[0-9]{1,2})?)'
    r'|([0-9][0-9,]*(?:\.[0-9]{1,2})?)\s*(USD|INR|EUR|GBP)',
    caseSensitive: false,
  ).firstMatch(text);
  if (match == null) return null;

  final String token =
      (match.group(1) ?? match.group(4) ?? '').trim().replaceAll('.', '');
  final String digits = (match.group(2) ?? match.group(3) ?? '').trim();
  if (digits.isEmpty) return null;

  final String currency =
      _currencyTokens[token.toLowerCase()] ?? fallbackCurrency;
  return Money.tryParse(digits, currency);
}

/// Convenience for building a parse issue tied to a spreadsheet row number.
///
/// Row 1 is the header, so a data row at index 0 is line 2 to the user — the
/// number they will see when they open the file.
IngestIssue rowIssue(int rowIndex, String detail, List<String> row) =>
    IngestIssue(
      detail: detail,
      lineNumber: rowIndex + 2,
      raw: row.join(', '),
    );
