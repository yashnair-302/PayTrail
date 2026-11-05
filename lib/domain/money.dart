/// Exact money arithmetic for the ledger.
///
/// Amounts are held as integer *minor units* (paise, cents) — never as
/// `double`. Binary floating point cannot represent 0.10 exactly, so summing
/// invoice lines as doubles drifts by fractions of a rupee and the aging
/// totals stop reconciling with the bank. Integers make every operation here
/// exact and every rounding decision explicit.
library;

/// Number of decimal places each supported currency subdivides into.
const Map<String, int> _currencyDecimals = <String, int>{
  'INR': 2,
  'USD': 2,
  'EUR': 2,
  'GBP': 2,
  'AUD': 2,
  'CAD': 2,
  'SGD': 2,
  'AED': 2,
  'JPY': 0,
};

/// Currencies the app offers in pickers, most likely first for this user base.
const List<String> kSupportedCurrencies = <String>[
  'INR',
  'USD',
  'EUR',
  'GBP',
  'AUD',
  'CAD',
  'SGD',
  'AED',
];

const String kDefaultCurrency = 'INR';

int decimalsForCurrency(String currency) =>
    _currencyDecimals[currency.toUpperCase()] ?? 2;

/// An amount in a single currency, stored as minor units.
///
/// Operations between two [Money] values require matching currencies; mixing
/// them throws rather than silently producing a meaningless number. Cross
/// currency totals are a reporting concern and need an explicit FX rate.
class Money implements Comparable<Money> {
  const Money(this.minorUnits, this.currency);

  const Money.zero(this.currency) : minorUnits = 0;

  /// Parses user input such as `1,250.50` into minor units.
  ///
  /// Returns `null` when [input] is not a well formed amount, so callers can
  /// surface a validation message instead of guessing.
  static Money? tryParse(String input, String currency) {
    final String cleaned = input.replaceAll(',', '').replaceAll(' ', '').trim();
    if (cleaned.isEmpty) return null;
    final RegExp pattern = RegExp(r'^-?\d*(\.\d*)?$');
    if (!pattern.hasMatch(cleaned) || cleaned == '-' || cleaned == '.') {
      return null;
    }
    final int decimals = decimalsForCurrency(currency);
    final int scale = _pow10(decimals);
    // Parse the two halves separately: going through `double` for the whole
    // value would reintroduce the representation error we are avoiding.
    if (cleaned.replaceAll(RegExp(r'[-.]'), '').length > 15) {
      return null; // Beyond any plausible invoice; reject instead of overflowing.
    }
    final bool negative = cleaned.startsWith('-');
    final String unsigned = negative ? cleaned.substring(1) : cleaned;
    final List<String> parts = unsigned.split('.');
    final int whole = parts[0].isEmpty ? 0 : int.parse(parts[0]);
    int fraction = 0;
    if (parts.length > 1 && parts[1].isNotEmpty) {
      final String digits = parts[1].padRight(decimals, '0');
      // Round rather than truncate when the user types more precision than the
      // currency has, e.g. 10.005 in INR becomes 10.01.
      final String kept = digits.substring(0, decimals);
      fraction = kept.isEmpty ? 0 : int.parse(kept);
      if (digits.length > decimals) {
        final int nextDigit = int.parse(digits[decimals]);
        if (nextDigit >= 5) fraction += 1;
      }
    }
    final int total = whole * scale + fraction;
    return Money(negative ? -total : total, currency.toUpperCase());
  }


  final int minorUnits;
  final String currency;

  int get decimals => decimalsForCurrency(currency);

  bool get isZero => minorUnits == 0;
  bool get isPositive => minorUnits > 0;
  bool get isNegative => minorUnits < 0;

  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money(minorUnits + other.minorUnits, currency);
  }

  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money(minorUnits - other.minorUnits, currency);
  }

  Money operator -() => Money(-minorUnits, currency);

  bool operator <(Money other) {
    _assertSameCurrency(other);
    return minorUnits < other.minorUnits;
  }

  bool operator <=(Money other) {
    _assertSameCurrency(other);
    return minorUnits <= other.minorUnits;
  }

  bool operator >(Money other) {
    _assertSameCurrency(other);
    return minorUnits > other.minorUnits;
  }

  bool operator >=(Money other) {
    _assertSameCurrency(other);
    return minorUnits >= other.minorUnits;
  }

  /// This amount scaled by [basisPoints] (1 bps = 0.01%), rounded half-up.
  ///
  /// Deductions are expressed in basis points rather than a `double` rate so
  /// that a 12.5% commission is the exact integer 1250 and the result of
  /// applying it is reproducible.
  Money percentage(int basisPoints) =>
      Money(_divideRoundHalfUp(minorUnits * basisPoints, 10000), currency);

  /// The larger of this amount and zero — used wherever a negative balance
  /// would be nonsense, such as outstanding after an overpayment.
  Money clampToZero() => minorUnits < 0 ? Money.zero(currency) : this;

  /// Plain decimal text without a currency symbol, e.g. `1250.50`.
  ///
  /// Presentation code formats for display; this exists so the domain and its
  /// tests can describe an amount without depending on locale data.
  String toDecimalString() {
    final int scale = _pow10(decimals);
    final int abs = minorUnits.abs();
    final String sign = minorUnits < 0 ? '-' : '';
    if (decimals == 0) return '$sign$abs';
    final String whole = (abs ~/ scale).toString();
    final String fraction = (abs % scale).toString().padLeft(decimals, '0');
    return '$sign$whole.$fraction';
  }

  void _assertSameCurrency(Money other) {
    if (other.currency != currency) {
      throw ArgumentError(
        'Cannot combine $currency with ${other.currency}; '
        'convert to a single currency first.',
      );
    }
  }

  @override
  int compareTo(Money other) {
    _assertSameCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  @override
  bool operator ==(Object other) =>
      other is Money &&
      other.minorUnits == minorUnits &&
      other.currency == currency;

  @override
  int get hashCode => Object.hash(minorUnits, currency);

  @override
  String toString() => '$currency ${toDecimalString()}';
}

/// Sums [amounts], which must all share [currency].
Money sumMoney(Iterable<Money> amounts, String currency) {
  int total = 0;
  for (final Money amount in amounts) {
    if (amount.currency != currency) {
      throw ArgumentError(
        'Cannot sum ${amount.currency} into a $currency total.',
      );
    }
    total += amount.minorUnits;
  }
  return Money(total, currency);
}

int _pow10(int exponent) {
  int result = 1;
  for (int i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}

/// Integer division rounding half away from zero, done without floating point.
int _divideRoundHalfUp(int numerator, int denominator) {
  if (numerator >= 0) {
    return (numerator * 2 + denominator) ~/ (denominator * 2);
  }
  return -((-numerator * 2 + denominator) ~/ (denominator * 2));
}
