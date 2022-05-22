import 'package:flutter/material.dart';
import 'package:kahwa/models/donation_supporter.dart';
import 'package:kahwa/utils/colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class SupporterCard extends StatelessWidget {
  const SupporterCard({
    Key? key,
    required this.donationSupporter,
  }) : super(key: key);

  final DonationSupporter donationSupporter;

  @override
  Widget build(BuildContext context) {
    String text = "";
    String kahwas = "kahwa";
    if (donationSupporter.donation!.kahwas! > 1) {
      kahwas = "kahwas";
    }

    if (donationSupporter.donation!.keep_private == true) {
      text = "Someone bought ${donationSupporter.donation!.kahwas} $kahwas";
    } else {
      text =
          "${donationSupporter.supporter!.name} bought ${donationSupporter.donation!.kahwas} $kahwas";
    }

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: donationSupporter.supporter!.image == null
                  ? const AssetImage("assets/cup.png")
                  : null,
              foregroundImage: donationSupporter.supporter!.image != null
                  ? NetworkImage(donationSupporter.supporter!.image!)
                  : null,
              backgroundColor: kTransparentColor,
            ),
            title: Text(text),
            subtitle: Text(
              timeago.format(donationSupporter.donation!.timestamp!.toDate()),
            ),
          ),
          donationSupporter.donation!.message!.isEmpty
              ? Container()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: kBrownColor.withOpacity(0.3),
                        ),
                      ),
                      color: kBrownColor.withOpacity(0.1),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(donationSupporter.donation!.message!),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
