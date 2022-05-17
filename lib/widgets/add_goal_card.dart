import 'package:flutter/material.dart';
import 'package:kahwa/utils/routes.dart';

class AddGoalCard extends StatelessWidget {
  const AddGoalCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: () => Navigator.pushNamed(context, routeGoal),
        horizontalTitleGap: 0,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        leading: Icon(
          Icons.flag_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text("Add Goal"),
      ),
    );
  }
}
