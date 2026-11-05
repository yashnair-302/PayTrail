import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/money.dart';
import '../../domain/money_bag.dart';
import '../theme.dart';

/// Small shared pieces used across the ledger screens.

/// A coloured pill showing a milestone's derived status.
class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key, this.dense = false});

  final MilestoneStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground) =
        context.statusColors.forStatus(status, Theme.of(context).colorScheme);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        describeStatus(status),
        style: (dense
                ? Theme.of(context).textTheme.labelSmall
                : Theme.of(context).textTheme.labelMedium)
            ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// One amount, in the currency it is denominated in.
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.amount, {
    super.key,
    this.style,
    this.muted = false,
  });

  final Money amount;
  final TextStyle? style;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Text(
      formatMoney(amount),
      style: (style ?? theme.textTheme.titleMedium)?.copyWith(
        fontWeight: FontWeight.w600,
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        color: muted ? theme.colorScheme.onSurfaceVariant : null,
      ),
    );
  }
}

/// A possibly multi-currency total, one line per currency.
///
/// Stacking rather than summing is the whole point of [MoneyBag]: there is no
/// honest single number for ₹80,000 plus $400 without an exchange rate.
class MoneyBagText extends StatelessWidget {
  const MoneyBagText(
    this.bag, {
    super.key,
    this.style,
    this.emptyLabel = '—',
    this.alignment = CrossAxisAlignment.end,
    this.muted = false,
  });

  final MoneyBag bag;
  final TextStyle? style;
  final String emptyLabel;
  final CrossAxisAlignment alignment;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (bag.isEmpty) {
      return Text(
        emptyLabel,
        style: (style ?? theme.textTheme.titleMedium)
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      );
    }

    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final Money amount in bag.amounts)
          MoneyText(amount, style: style, muted: muted),
      ],
    );
  }
}

/// A labelled row in a details panel.
class DetailRow extends StatelessWidget {
  const DetailRow({
    required this.label,
    required this.value,
    super.key,
    this.emphasised = false,
  });

  final String label;
  final Widget value;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: emphasised ? FontWeight.w600 : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          value,
        ],
      ),
    );
  }
}

/// Section heading used between cards.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 0.4,
                  ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Shown when a list has nothing in it yet.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (action != null) ...<Widget>[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Renders an [AsyncValue] with consistent loading and error states.
///
/// Every screen reads a stream off the database, and every one of them can
/// fail the same way. Centralising it means an error surfaces as a readable
/// message instead of a red screen, and never as a spinner that hangs forever.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    required this.value,
    required this.builder,
    super.key,
    this.loading,
  });

  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) builder;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (T data) => builder(context, data),
      loading: () =>
          loading ?? const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stack) => EmptyState(
        icon: Icons.error_outline,
        title: 'Could not load this',
        message: '$error',
      ),
    );
  }
}

/// Asks before doing something that cannot be undone.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
  bool destructive = true,
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                )
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Shows a one-line confirmation at the bottom of the screen.
void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
