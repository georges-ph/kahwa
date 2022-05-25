import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/enums/currency.dart';
import 'package:kahwa/models/goal.dart';
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/routes.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/statics.dart';
import 'package:kahwa/utils/typography.dart';

class GoalCard extends StatefulWidget {
  const GoalCard({
    Key? key,
    this.goal,
    this.deleted,
  }) : super(key: key);

  final Goal? goal;
  final Function(bool)? deleted;

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  @override
  void initState() {
    super.initState();
    Statics.goal = widget.goal!;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: Statics.goal.id != FirebaseAuth.instance.currentUser!.uid
          ? null
          : () async {
              final deleted = await Navigator.pushNamed(context, routeGoal);
              widget.deleted!(deleted == true ? true : false);
              setState(() {});
            },
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Goal: ${Statics.goal.title}",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: kSemiBoldFontWeight,
                    ),
              ),
              verticalSpace(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LinearProgressIndicator(
                  value:
                      (Statics.goal.current! / Statics.goal.target!).toDouble(),
                  backgroundColor: kGreyColor.withOpacity(0.1),
                  minHeight: 16,
                ),
              ),
              verticalSpace(height: 8),
              Text(
                  "${Currency.lbp.name.toUpperCase()} ${Statics.goal.current} of ${Currency.lbp.name.toUpperCase()} ${Statics.goal.target}"),
              verticalSpace(height: 8),
              Text("${Statics.goal.description}"),
            ],
          ),
        ),
      ),
    );
  }
}
