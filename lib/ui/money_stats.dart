import 'package:flutter/material.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/widgets.dart';

/// Totals such as received, spent and withdrawn, side by side: each a small
/// label with its amount in every currency under it.
class MoneyStats extends StatelessWidget {
  const MoneyStats({super.key, required this.stats, this.framed = true});

  final List<(String, Amounts)> stats;

  /// In a card of its own; false inside another card.
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, (label, amounts)) in stats.indexed) ...[
          if (i > 0)
            Container(
              width: 1,
              height: 56,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: context.kahwa.border,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.text.labelMedium?.copyWith(
                    color: context.kahwa.muted,
                  ),
                ),
                const SizedBox(height: 6),
                for (final currency in Currency.values)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      context.money(amounts.of(currency), currency),
                      style: context.text.titleSmall,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
    return framed
        ? Panel(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: row,
          )
        : row;
  }
}
