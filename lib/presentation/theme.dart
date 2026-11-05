import 'package:flutter/material.dart';

import '../domain/aging.dart';
import '../domain/entities/milestone.dart';

/// App theme and the semantic colours the ledger needs.
///
/// Material's scheme gives primary/secondary/error, but a payments app needs
/// "settled", "late" and "partly there" to read at a glance, and those must
/// survive both light and dark mode. They are defined here once, as a theme
/// extension, so no widget invents its own green.

@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.paidContainer,
    required this.onPaidContainer,
    required this.overdueContainer,
    required this.onOverdueContainer,
    required this.partialContainer,
    required this.onPartialContainer,
    required this.neutralContainer,
    required this.onNeutralContainer,
  });

  factory StatusColors.of(Brightness brightness) {
    final bool dark = brightness == Brightness.dark;
    return StatusColors(
      paidContainer: dark ? const Color(0xFF12321F) : const Color(0xFFD9F2E3),
      onPaidContainer: dark ? const Color(0xFF7FD6A3) : const Color(0xFF0F5132),
      overdueContainer: dark ? const Color(0xFF3B1418) : const Color(0xFFFBE0E3),
      onOverdueContainer:
          dark ? const Color(0xFFFF9BA6) : const Color(0xFF8C1D2A),
      partialContainer: dark ? const Color(0xFF3A2E10) : const Color(0xFFFBEFD2),
      onPartialContainer:
          dark ? const Color(0xFFF2C66A) : const Color(0xFF7A5400),
      neutralContainer: dark ? const Color(0xFF26282C) : const Color(0xFFECEEF1),
      onNeutralContainer:
          dark ? const Color(0xFFB6BAC1) : const Color(0xFF4B4F56),
    );
  }

  final Color paidContainer;
  final Color onPaidContainer;
  final Color overdueContainer;
  final Color onOverdueContainer;
  final Color partialContainer;
  final Color onPartialContainer;
  final Color neutralContainer;
  final Color onNeutralContainer;

  /// Background and foreground for [status].
  (Color, Color) forStatus(MilestoneStatus status, ColorScheme scheme) {
    return switch (status) {
      MilestoneStatus.paid => (paidContainer, onPaidContainer),
      MilestoneStatus.overdue => (overdueContainer, onOverdueContainer),
      MilestoneStatus.partiallyPaid => (partialContainer, onPartialContainer),
      MilestoneStatus.invoiced => (
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
        ),
      MilestoneStatus.pending ||
      MilestoneStatus.cancelled =>
        (neutralContainer, onNeutralContainer),
    };
  }

  @override
  StatusColors copyWith({
    Color? paidContainer,
    Color? onPaidContainer,
    Color? overdueContainer,
    Color? onOverdueContainer,
    Color? partialContainer,
    Color? onPartialContainer,
    Color? neutralContainer,
    Color? onNeutralContainer,
  }) {
    return StatusColors(
      paidContainer: paidContainer ?? this.paidContainer,
      onPaidContainer: onPaidContainer ?? this.onPaidContainer,
      overdueContainer: overdueContainer ?? this.overdueContainer,
      onOverdueContainer: onOverdueContainer ?? this.onOverdueContainer,
      partialContainer: partialContainer ?? this.partialContainer,
      onPartialContainer: onPartialContainer ?? this.onPartialContainer,
      neutralContainer: neutralContainer ?? this.neutralContainer,
      onNeutralContainer: onNeutralContainer ?? this.onNeutralContainer,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      paidContainer: Color.lerp(paidContainer, other.paidContainer, t)!,
      onPaidContainer: Color.lerp(onPaidContainer, other.onPaidContainer, t)!,
      overdueContainer:
          Color.lerp(overdueContainer, other.overdueContainer, t)!,
      onOverdueContainer:
          Color.lerp(onOverdueContainer, other.onOverdueContainer, t)!,
      partialContainer:
          Color.lerp(partialContainer, other.partialContainer, t)!,
      onPartialContainer:
          Color.lerp(onPartialContainer, other.onPartialContainer, t)!,
      neutralContainer:
          Color.lerp(neutralContainer, other.neutralContainer, t)!,
      onNeutralContainer:
          Color.lerp(onNeutralContainer, other.onNeutralContainer, t)!,
    );
  }
}

/// The ordinal ramp used by the aging chart.
///
/// Aging bands are one ordered measure — how late the money is — so they get a
/// single-hue ramp stepping away from the surface as severity rises, not a
/// rainbow of unrelated hues. "Not yet due" sits outside the ramp in neutral
/// grey because it is a different kind of thing: outstanding, but healthy.
///
/// The four red steps were validated against this app's actual Material
/// surfaces (`#eff5f1` light, `#171d1b` dark) for monotone lightness, visible
/// step gaps, single hue, and a near-surface end clearing 2:1 contrast. They
/// are deliberately distinct from the reserved status colours so a band can
/// never be mistaken for a state badge.
@immutable
class AgingColors extends ThemeExtension<AgingColors> {
  const AgingColors({required this.notYetDue, required this.overdueRamp});

  factory AgingColors.of(Brightness brightness) {
    final bool dark = brightness == Brightness.dark;
    return AgingColors(
      notYetDue: dark ? const Color(0xFF4A524E) : const Color(0xFFBFCAC4),
      overdueRamp: dark
          // On a dark surface severity reads as increasing brightness.
          ? const <Color>[
              Color(0xFF8A382F),
              Color(0xFFB04F44),
              Color(0xFFD47367),
              Color(0xFFF0A396),
            ]
          : const <Color>[
              Color(0xFFE28A80),
              Color(0xFFCC5A50),
              Color(0xFFA83630),
              Color(0xFF761F1B),
            ],
    );
  }

  final Color notYetDue;

  /// Four steps, 0–30 through 90+.
  final List<Color> overdueRamp;

  /// The fill for [bucket].
  Color forBucket(AgingBucket bucket) => switch (bucket) {
        AgingBucket.notYetDue => notYetDue,
        AgingBucket.days0to30 => overdueRamp[0],
        AgingBucket.days31to60 => overdueRamp[1],
        AgingBucket.days61to90 => overdueRamp[2],
        AgingBucket.days90plus => overdueRamp[3],
      };

  @override
  AgingColors copyWith({Color? notYetDue, List<Color>? overdueRamp}) =>
      AgingColors(
        notYetDue: notYetDue ?? this.notYetDue,
        overdueRamp: overdueRamp ?? this.overdueRamp,
      );

  @override
  AgingColors lerp(ThemeExtension<AgingColors>? other, double t) {
    if (other is! AgingColors) return this;
    return AgingColors(
      notYetDue: Color.lerp(notYetDue, other.notYetDue, t)!,
      overdueRamp: <Color>[
        for (int i = 0; i < overdueRamp.length; i++)
          Color.lerp(overdueRamp[i], other.overdueRamp[i], t)!,
      ],
    );
  }
}

/// Convenience accessor so widgets read `context.statusColors`.
extension StatusColorsContext on BuildContext {
  StatusColors get statusColors =>
      Theme.of(this).extension<StatusColors>() ??
      StatusColors.of(Theme.of(this).brightness);

  AgingColors get agingColors =>
      Theme.of(this).extension<AgingColors>() ??
      AgingColors.of(Theme.of(this).brightness);
}

ThemeData buildTheme(Brightness brightness) {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF1F6F5C), // Ledger green, not a platform's brand.
    brightness: brightness,
  );

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    extensions: <ThemeExtension<dynamic>>[
      StatusColors.of(brightness),
      AgingColors.of(brightness),
    ],
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: scheme.surfaceTint,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: false,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
    ),
  );
}
