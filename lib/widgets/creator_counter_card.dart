import 'package:flutter/material.dart';
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/typography.dart';

class CreatorCounterCard extends StatelessWidget {
  const CreatorCounterCard({
    Key? key,
    required this.counter,
    required this.title,
  }) : super(key: key);

  final int counter;
  final String title;

  @override
  Widget build(BuildContext context) {
    Size _screenSize = MediaQuery.of(context).size;
    return Container(
      width: _screenSize.width * 0.25,
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ),
      decoration: ShapeDecoration(
        color: kGreyColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Text(
            counter.toString(),
            style: const TextStyle(
              fontWeight: kSemiBoldFontWeight,
              fontSize: 18,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
