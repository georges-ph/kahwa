// ignore_for_file: prefer_const_constructors

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
                  ? AssetImage("assets/cup.png")
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
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                        padding: EdgeInsets.symmetric(
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

    // TODO: try to change it to ListTile
    // return Card(
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(16),
    //   ),
    //   child: Padding(
    //     padding: const EdgeInsets.all(16),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Row(
    //           children: [
    //             donationSupporter.supporter!.image != null
    //                 ? Image.network(
    //                     donationSupporter.supporter!.image!,
    //                     width: 32,
    //                   )
    //                 : Image.asset(
    //                     "assets/cup.png",
    //                     width: 32,
    //                   ),
    //             horizontalSpace(width: 16),
    //             Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Text(
    //                   text,
    //                   style: Theme.of(context).textTheme.labelLarge,
    //                 ),
    //                 Text(
    //                   timeago.format(
    //                       donationSupporter.donation!.timestamp!.toDate()),
    //                   style: Theme.of(context).textTheme.bodySmall,
    //                 ),
    //               ],
    //             ),
    //           ],
    //         ),
    //         donationSupporter.donation!.message!.isEmpty
    //             ? Container()
    //             : verticalSpace(height: 12),
    //         donationSupporter.donation!.message!.isEmpty
    //             ? Container()
    //             : SizedBox(
    //                 width: double.infinity,
    //                 child: Card(
    //                   shape: RoundedRectangleBorder(
    //                     borderRadius: BorderRadius.circular(8),
    //                     side: BorderSide(
    //                       color: kBrownColor.withOpacity(0.3),
    //                     ),
    //                   ),
    //                   color: kBrownColor.withOpacity(0.1),
    //                   elevation: 0,
    //                   child: Padding(
    //                     padding: EdgeInsets.symmetric(
    //                       horizontal: 16,
    //                       vertical: 8,
    //                     ),
    //                     child: Text(donationSupporter.donation!.message!),
    //                   ),
    //                 ),
    //               ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
