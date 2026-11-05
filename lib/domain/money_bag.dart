import 'money.dart';

/// A total that may span several currencies.
///
/// A freelancer with Upwork work in USD and direct Indian clients in INR has no
/// single "outstanding" number until someone picks an exchange rate. Rather
/// than invent one, every aggregate in the app returns a [MoneyBag] and the UI
/// renders each currency on its own line. The type makes the multi-currency
/// case impossible to forget, because there is no way to read a bare amount out
/// of it without naming a currency.
class MoneyBag {
  const MoneyBag._(this._byCurrency);

  factory MoneyBag.empty() => const MoneyBag._(<String, int>{});

  factory MoneyBag.of(Iterable<Money> amounts) {
    final Map<String, int> totals = <String, int>{};
    for (final Money amount in amounts) {
      if (amount.isZero) continue;
      totals[amount.currency] = (totals[amount.currency] ?? 0) + amount.minorUnits;
    }
    return MoneyBag._(totals);
  }

  final Map<String, int> _byCurrency;

  bool get isEmpty => _byCurrency.values.every((int value) => value == 0);
  bool get isNotEmpty => !isEmpty;

  /// Currencies present, in a stable order so totals do not reshuffle between
  /// rebuilds.
  List<String> get currencies {
    final List<String> keys = _byCurrency.keys
        .where((String key) => _byCurrency[key] != 0)
        .toList()
      ..sort();
    // INR first when present: it is the reporting currency for this user base.
    keys.sort((String a, String b) {
      if (a == b) return 0;
      if (a == kDefaultCurrency) return -1;
      if (b == kDefaultCurrency) return 1;
      return a.compareTo(b);
    });
    return keys;
  }

  /// Every non-zero total, one per currency.
  List<Money> get amounts => <Money>[
        for (final String currency in currencies)
          Money(_byCurrency[currency]!, currency),
      ];

  /// The total in [currency]; zero when this bag holds none of it.
  Money inCurrency(String currency) =>
      Money(_byCurrency[currency] ?? 0, currency);

  MoneyBag operator +(MoneyBag other) {
    final Map<String, int> merged = Map<String, int>.of(_byCurrency);
    other._byCurrency.forEach((String currency, int value) {
      merged[currency] = (merged[currency] ?? 0) + value;
    });
    return MoneyBag._(merged);
  }

  MoneyBag add(Money amount) => this + MoneyBag.of(<Money>[amount]);

  @override
  String toString() => amounts.map((Money m) => m.toString()).join(' + ');
}
