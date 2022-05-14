import 'package:flutter/material.dart';
import 'package:kahwa/models/donation.dart';
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:timeago/timeago.dart' as timeago;

class SupporterCard extends StatelessWidget {
  const SupporterCard({
    Key? key,
    required this.donation,
  }) : super(key: key);

  final Donation donation;

  @override
  Widget build(BuildContext context) {
    String text = "";
    String kahwas = "kahwa";
    if (donation.kahwas! > 1) {
      kahwas = "kahwas";
    }

    if (donation.keep_private == true) {
      text = "Someone bought ${donation.kahwas} $kahwas";
    } else {
      text = "${donation.supporter!.name} bought ${donation.kahwas} $kahwas";
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  // TODO: add network image
                  "assets/fenjen.png",
                  width: 32,
                ),
                horizontalSpace(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      timeago.format(donation.timestamp!.toDate()),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            donation.message!.isEmpty ? Container() : verticalSpace(height: 12),
            donation.message!.isEmpty
                ? Container()
                : SizedBox(
                    width: double.infinity,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: kRedColor.withOpacity(0.3),
                        ),
                      ),
                      color: kRedColor.withOpacity(0.1),
                      elevation: 0,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(donation.message!),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
