import 'package:flutter/material.dart';
import 'package:kahwa/core/colors.dart';
import 'package:kahwa/models/currency.dart';
import 'package:kahwa/models/goal.dart';
import 'package:kahwa/widgets/page_body.dart';

/// Progress of the goal of a creator. [onTap] is set for the owner, who can
/// open the goal to edit it.
class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal, this.onTap});

  final Goal goal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final current = Currency.lbp.format(goal.current);
    final target = Currency.lbp.format(goal.target);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle('Goal: ${goal.title}'),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: goal.progress,
                backgroundColor: kFillColor,
                minHeight: 16,
                borderRadius: BorderRadius.circular(16),
              ),
              const SizedBox(height: 8),
              Text('$current of $target'),
              const SizedBox(height: 8),
              Text(goal.description),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown to creators who do not have a goal yet.
class AddGoalCard extends StatelessWidget {
  const AddGoalCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        leading: Icon(
          Icons.flag_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Add Goal'),
      ),
    );
  }
}
