import 'package:flutter/material.dart';
import 'package:kahwa/enums/currency.dart';
import 'package:kahwa/models/goal.dart';
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/routes.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/typography.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
    Key? key,
    this.goal,
  }) : super(key: key);

  final Goal? goal;

  @override
  Widget build(BuildContext context) {
    if (goal == null) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const ListTile(
          // TODO: add goal when tapped
          horizontalTitleGap: 0,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 24,
          ),
          leading: Icon(
            Icons.flag_rounded,
            color: kRedColor,
          ),
          title: Text("Add Goal"),
        ),
      );
    }

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, routeGoal),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Goal: ${goal!.title}",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: kSemiBoldFontWeight,
                    ),
              ),
              verticalSpace(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LinearProgressIndicator(
                  value: 0.3,
                  backgroundColor: kGreyColor.withOpacity(0.1),
                  minHeight: 16,
                ),
              ),
              verticalSpace(height: 8),
              Text(
                  "${Currency.lbp.name.toUpperCase()} ${goal!.current} of ${Currency.lbp.name.toUpperCase()} ${goal!.target}"),
              verticalSpace(height: 8),
              Text("${goal!.description}"),
            ],
          ),
        ),
      ),
    );
  }
}
