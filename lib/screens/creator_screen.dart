// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/models/donation.dart';
import 'package:kahwa/models/supporter.dart';
import 'package:kahwa/models/user.dart' as user_model;
import 'package:kahwa/screen_arguments/fans_supporters_args.dart';
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/routes.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/typography.dart';
import 'package:kahwa/widgets/creator_counter_card.dart';
import 'package:kahwa/widgets/goal_card.dart';
import 'package:kahwa/widgets/supporter_card.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';

class CreatorScreen extends StatefulWidget {
  const CreatorScreen({
    Key? key,
    required this.creatorId,
  }) : super(key: key);

  final String creatorId;

  @override
  State<CreatorScreen> createState() => _CreatorScreenState();
}

class _CreatorScreenState extends State<CreatorScreen> {
  late Size _screenSize;

  final List<Donation> _donationsList = [];
  final List<Supporter> _supportersList = [];

  int _kahwas = 0;

  final User _user = FirebaseAuth.instance.currentUser!;
  final DocumentReference _appDocument =
      FirebaseFirestore.instance.collection("kahwa").doc("AppCollections");

  late Future<void> _runFuture;

  late user_model.User _userModel;

  @override
  void initState() {
    super.initState();
    _appDocument
        .collection("Donations")
        .where("creator_id", isEqualTo: _user.uid)
        .orderBy("timestamp", descending: true)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isEmpty) {
        return;
      }
      _donationsList.addAll(querySnapshot.docs
          .map((document) => Donation.fromMap(document.data()))
          .toList());

      _donationsList.forEach((donation) {
        _kahwas += donation.kahwas!;

        if (!_supportersList.contains(donation.supporter!)) {
          _supportersList.add(donation.supporter!);
        }
      });
    });

    _runFuture = _getUserData();
  }

  Future<void> _getUserData() async {
    DocumentSnapshot<Map<String, dynamic>> userDocument =
        await _appDocument.collection("Users").doc(widget.creatorId).get();

    _userModel =
        user_model.User.fromMap(userDocument.data() as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.share_rounded),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _runFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(
              child: Text(
                "Error getting data",
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(24),
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: _screenSize.width / 5,
                      backgroundImage: _userModel.image != null
                          ? NetworkImage(_userModel.image!)
                          : null,
                      backgroundColor:
                          _userModel.image == null ? kRedColor : null,
                      child: _userModel.image == null
                          ? Text(
                              getInitials(_userModel.name!),
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(
                                    color: kWhiteColor,
                                  ),
                            )
                          : null,
                    ),
                  ),
                  verticalSpace(),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      _userModel.name!,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: kBoldFontWeight,
                          ),
                    ),
                  ),
                  verticalSpace(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () => _userModel.id != _user.uid
                            ? null
                            : Navigator.pushNamed(
                                context,
                                routeFansSupporters,
                                arguments: FansSupportersArgs(
                                  title: _userModel.fans!.length == 1
                                      ? "Fan"
                                      : "Fans",
                                  list: _userModel.fans!,
                                ),
                              ),
                        child: CreatorCounterCard(
                          counter: _userModel.fans!.length,
                          title: _userModel.fans!.length == 1 ? "Fan" : "Fans",
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _userModel.id != _user.uid
                            ? null
                            : Navigator.pushNamed(
                                context,
                                routeFansSupporters,
                                arguments: FansSupportersArgs(
                                  title: _supportersList.length == 1
                                      ? "Supporter"
                                      : "Supporters",
                                  list: _supportersList,
                                ),
                              ),
                        child: CreatorCounterCard(
                          counter: _supportersList.length,
                          title: _supportersList.length == 1
                              ? "Supporter"
                              : "Supporters",
                        ),
                      ),
                      CreatorCounterCard(
                        counter: _kahwas,
                        title: _kahwas == 1 ? "kahwa" : "kahwas",
                      ),
                    ],
                  ),
                  verticalSpace(),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            routeDonate,
                            arguments: _userModel.id,
                          ),
                          icon: Image.asset(
                            "assets/fenjen.png",
                            width: 24,
                          ),
                          label: Text("Buy a kahwa"),
                        ),
                      ),
                      horizontalSpace(width: 16),
                      GestureDetector(
                        onTap: () async {
                         Supporter supporter= Supporter(
                              id: _user.uid,
                              name: _user.displayName,
                              image: _user.photoURL,
                            );

                          if (_userModel.fans!.contains(supporter)) {
                            _userModel.fans!.remove(supporter);
                          } else {
                            _userModel.fans!.add(supporter);
                          }

                          setState(() {});

                          await _appDocument
                              .collection("Users")
                              .doc(widget.creatorId)
                              .update(_userModel.toMap());
                        },
                        child: DecoratedBox(
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: kRedColor,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  _userModel.fans!.contains(_user.uid)
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: kRedColor,
                                ),
                                Text(
                                  "Fan",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(
                                        color: kRedColor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  verticalSpace(),
                  GoalCard(goal: _userModel.goal),
                  verticalSpace(),
                  _userModel.about == null
                      ? Container()
                      : Text(
                          "About",
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontWeight: kSemiBoldFontWeight,
                                  ),
                        ),
                  _userModel.about == null
                      ? Container()
                      : verticalSpace(height: 8),
                  _userModel.about == null
                      ? Container()
                      : ReadMoreText(
                          "${_userModel.about}",
                          style: Theme.of(context).textTheme.bodyMedium,
                          trimMode: TrimMode.Line,
                          trimLines: 3,
                          trimCollapsedText: "Show More",
                          moreStyle:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontWeight: kBoldFontWeight,
                                    color: kRedColor,
                                  ),
                          trimExpandedText: "Show Less",
                          lessStyle:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontWeight: kBoldFontWeight,
                                    color: kRedColor,
                                  ),
                        ),
                  verticalSpace(height: 16),
                  _userModel.website == null
                      ? Container()
                      : GestureDetector(
                          onTap: () async {
                            if (!await launchUrl(
                                Uri.parse("http://${_userModel.website}"))) {
                              SnackBar snackBar =
                                  SnackBar(content: Text("Cannot open link"));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          },
                          child: Row(
                            children: [
                              Icon(Icons.link_rounded),
                              horizontalSpace(),
                              Text(
                                "${_userModel.website}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: kRedColor,
                                    ),
                              ),
                            ],
                          ),
                        ),
                  verticalSpace(),
                  _donationsList.isEmpty
                      ? Container()
                      : Text(
                          "Recent Supporters",
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontWeight: kSemiBoldFontWeight,
                                  ),
                        ),
                  _donationsList.isEmpty
                      ? Container()
                      : verticalSpace(height: 16),
                  ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _donationsList.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return verticalSpace(height: 16);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return SupporterCard(
                        donation: _donationsList[index],
                      );
                    },
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
