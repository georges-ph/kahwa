import 'package:firebase_auth/firebase_auth.dart';
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
    return GestureDetector(
      onTap: goal!.id != FirebaseAuth.instance.currentUser!.uid
          ? null
          : () => Navigator.pushNamed(context, routeGoal),
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
                  value: (goal!.current! / goal!.target!).toDouble(),
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
