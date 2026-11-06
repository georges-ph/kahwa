import 'package:flutter/material.dart';
import 'package:kahwa/models/goal.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/widgets.dart';

/// A goal and how far along it is.
class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    this.onTap,
    this.compact = false,
  });

  final Goal goal;
  final VoidCallback? onTap;

  /// Leaves out the description, for lists.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final percent = (goal.progress * 100).floor();
    return Panel(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_rounded, color: context.colors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.goalLabel,
                  style: context.text.labelLarge?.copyWith(
                    color: context.kahwa.muted,
                  ),
                ),
              ),
              if (goal.isReached)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.kahwa.successContainer,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    l10n.goalReached,
                    style: context.text.labelMedium?.copyWith(
                      color: context.kahwa.success,
                    ),
                  ),
                )
              else
                Text('$percent%', style: context.text.titleMedium),
            ],
          ),
          const SizedBox(height: 10),
          Text(goal.title, style: context.text.titleMedium),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: goal.progress),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) =>
                  LinearProgressIndicator(value: value, minHeight: 10),
            ),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: context.money(goal.current, goal.currency),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(
                  text:
                      ' ${l10n.goalOf(context.money(goal.target, goal.currency))}',
                ),
              ],
            ),
            style: context.text.bodyMedium,
          ),
          if (!compact && goal.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              goal.description,
              style: context.text.bodyMedium?.copyWith(
                color: context.kahwa.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
