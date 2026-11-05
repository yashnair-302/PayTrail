/// Where money comes from, and what each channel costs.
library;

/// Built-in source identifiers.
///
/// These are plain strings rather than an enum because users can add their own
/// sources (a fourth marketplace, a new retainer channel) and the rest of the
/// app must treat those exactly like the shipped ones. The constants exist so
/// seeding and the Module 3 parsers can refer to the built-ins safely.
abstract final class SourceIds {
  static const String upwork = 'upwork';
  static const String fiverr = 'fiverr';
  static const String direct = 'direct';
  static const String retainer = 'retainer';
}

/// A payment channel and its current deduction rates.
///
/// Rates live here, per source, instead of being hardcoded at the call site:
/// Fiverr and Upwork both revise their commission occasionally, and a user on a
/// legacy plan may sit on a different rate entirely. Changing this row changes
/// what *future* milestones default to; existing milestones keep the rate they
/// were created with (see [Milestone.commissionRateBps]).
class PaymentSource {
  const PaymentSource({
    required this.id,
    required this.displayName,
    required this.commissionRateBps,
    required this.defaultTdsRateBps,
    required this.isBuiltIn,
    required this.sortOrder,
  });

  final String id;
  final String displayName;

  /// Platform commission in basis points; 2000 = 20%.
  final int commissionRateBps;

  /// Tax deducted at source in basis points, applied by default to new
  /// milestones on this source. Indian clients commonly deduct 10% under
  /// section 194J; marketplaces normally do not.
  final int defaultTdsRateBps;

  /// True for the four sources the app ships with, which cannot be deleted
  /// because parsers and seeded data reference their ids.
  final bool isBuiltIn;

  final int sortOrder;

  double get commissionRatePercent => commissionRateBps / 100;
  double get defaultTdsRatePercent => defaultTdsRateBps / 100;

  PaymentSource copyWith({
    String? displayName,
    int? commissionRateBps,
    int? defaultTdsRateBps,
    int? sortOrder,
  }) {
    return PaymentSource(
      id: id,
      displayName: displayName ?? this.displayName,
      commissionRateBps: commissionRateBps ?? this.commissionRateBps,
      defaultTdsRateBps: defaultTdsRateBps ?? this.defaultTdsRateBps,
      isBuiltIn: isBuiltIn,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) => other is PaymentSource && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// The rows inserted on first launch. Commission figures are the public
/// standard rates at the time of writing and are editable in Settings.
const List<PaymentSource> kBuiltInSources = <PaymentSource>[
  PaymentSource(
    id: SourceIds.upwork,
    displayName: 'Upwork',
    commissionRateBps: 1000, // 10%
    defaultTdsRateBps: 0,
    isBuiltIn: true,
    sortOrder: 0,
  ),
  PaymentSource(
    id: SourceIds.fiverr,
    displayName: 'Fiverr',
    commissionRateBps: 2000, // 20%
    defaultTdsRateBps: 0,
    isBuiltIn: true,
    sortOrder: 1,
  ),
  PaymentSource(
    id: SourceIds.direct,
    displayName: 'Direct',
    commissionRateBps: 0,
    defaultTdsRateBps: 1000, // 10% TDS under s.194J is the common default
    isBuiltIn: true,
    sortOrder: 2,
  ),
  PaymentSource(
    id: SourceIds.retainer,
    displayName: 'Retainer',
    commissionRateBps: 0,
    defaultTdsRateBps: 1000,
    isBuiltIn: true,
    sortOrder: 3,
  ),
];
