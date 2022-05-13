import 'package:flutter/material.dart';
import 'package:kahwa/enums/currency.dart';
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/typography.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    Key? key,
    required this.title,
    required this.lbp,
    required this.usd,
  }) : super(key: key);

  final String title;
  final int lbp;
  final int usd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: kGreyColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: kSemiBoldFontWeight,
                ),
          ),
          verticalSpace(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Currency.lbp.name.toUpperCase(),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                lbp.toString(),
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: kGreyColor,
                    ),
              ),
            ],
          ),
          verticalSpace(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Currency.usd.name.toUpperCase(),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                usd.toString(),
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: kGreyColor,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
