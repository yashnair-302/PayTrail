import 'package:flutter/material.dart';

import '../../core/formatting.dart';
import '../../domain/aging.dart';
import '../../domain/money.dart';
import '../theme.dart';

/// The aging table: how much is outstanding, and how late it is.
///
/// A horizontal bar per band, one ordered measure, one hue ramp. Bar lengths
/// are drawn for a single [currency] — lengths are only comparable within one
/// currency, and inventing an exchange rate to make one bar out of ₹ and $
/// would be a lie the chart cannot signal. The screen above offers a currency
/// selector when more than one is in play.
///
/// Values sit in their own trailing column rather than at each bar tip: a tip
/// label on a near-zero bar either collides with the axis or gets clipped, and
/// a fixed column also lets the figures align on the decimal point.
class AgingChart extends StatelessWidget {
  const AgingChart({
    required this.bands,
    required this.currency,
    super.key,
  });

  final List<AgingBand> bands;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AgingColors palette = context.agingColors;

    final List<int> values = <int>[
      for (final AgingBand band in bands)
        band.amount.inCurrency(currency).minorUnits,
    ];
    final int maxValue = values.fold<int>(0, (int a, int b) => a > b ? a : b);

    if (maxValue == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Nothing outstanding in $currency.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < bands.length; i++)
          _AgingRow(
            band: bands[i],
            amount: Money(values[i], currency),
            fraction: maxValue == 0 ? 0 : values[i] / maxValue,
            color: palette.forBucket(bands[i].bucket),
          ),
      ],
    );
  }
}

class _AgingRow extends StatelessWidget {
  const _AgingRow({
    required this.band,
    required this.amount,
    required this.fraction,
    required this.color,
  });

  final AgingBand band;
  final Money amount;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool empty = amount.isZero;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 84,
            child: Text(
              band.bucket.label,
              // Labels wear text ink, never the band colour: the bar beside
              // them already carries the identity.
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // A non-zero band never renders as nothing; without a floor a
                // ₹500 debt beside a ₹5,00,000 one would vanish entirely.
                final double width = empty
                    ? 0
                    : (constraints.maxWidth * fraction).clamp(
                        4.0,
                        constraints.maxWidth,
                      );
                return Stack(
                  children: <Widget>[
                    Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Container(
                      height: 14,
                      width: width,
                      decoration: BoxDecoration(
                        color: color,
                        // Square at the baseline, 4px rounded at the data end.
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(2),
                          right: Radius.circular(4),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 96,
            child: Text(
              empty ? '—' : formatMoney(amount),
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                color: empty
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
                fontWeight: empty ? null : FontWeight.w600,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
