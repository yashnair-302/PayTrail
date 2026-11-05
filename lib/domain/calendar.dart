/// Calendar-date helpers.
///
/// Due dates are *dates*, not instants: a milestone due on the 30th is due on
/// the 30th regardless of the hour. Storing a raw `DateTime.now()` makes
/// "days overdue" depend on the time of day the row happened to be created,
/// which shows up as off-by-one aging buckets. Everything date-shaped is
/// normalised through [dateOnly] before it is stored or compared.
library;

/// Strips the time component, keeping the calendar day in local time.
DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// Today, with no time component.
DateTime today() => dateOnly(DateTime.now());

/// Whole days from [from] to [to]; negative when [to] is earlier.
///
/// Both ends are normalised first, so a daylight-saving shift in between cannot
/// turn a 7-day gap into 6 days and 23 hours.
int daysBetween(DateTime from, DateTime to) {
  final DateTime a = dateOnly(from);
  final DateTime b = dateOnly(to);
  return b.difference(a).inDays;
}
