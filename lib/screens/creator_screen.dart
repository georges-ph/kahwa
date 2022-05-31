import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/enums/colors.dart' as colors_enum;
import 'package:kahwa/models/donation.dart';
import 'package:kahwa/models/donation_supporter.dart';
import 'package:kahwa/models/goal.dart';
import 'package:kahwa/models/user.dart' as user_model;
import 'package:kahwa/screen_arguments/fans_supporters_args.dart';
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/routes.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/statics.dart';
import 'package:kahwa/utils/typography.dart';
import 'package:kahwa/widgets/add_goal_card.dart';
import 'package:kahwa/widgets/creator_counter_card.dart';
import 'package:kahwa/widgets/goal_card.dart';
import 'package:kahwa/widgets/supporter_card.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
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

  final List<String> _supportersList = [];
  final List<DonationSupporter> _donationSupporterList = [];

  int _kahwas = 0;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  late User _user;
  late DocumentReference _appDocument;
  late DocumentReference<Map<String, dynamic>> _goalDocument;

  late Future<void> _runFuture;

  late user_model.User _userModel;
  late Color _creatorColor;
  late Goal _goal;

  @override
  void initState() {
    super.initState();

    _user = _firebaseAuth.currentUser!;
    _appDocument = _firebaseFirestore.collection("kahwa").doc("AppCollections");
    _goalDocument = _appDocument.collection("Goals").doc(widget.creatorId);

    _runFuture = _getUserData();
  }

  Future<void> _getUserData() async {
    DocumentSnapshot<Map<String, dynamic>> userDocument =
        await _appDocument.collection("Users").doc(widget.creatorId).get();

    _userModel =
        user_model.User.fromMap(userDocument.data() as Map<String, dynamic>);

    _creatorColor = colors_enum.getColor(_userModel.color!);
    Statics.creatorColor = _creatorColor;

    DocumentSnapshot<Map<String, dynamic>> goalDocument =
        await _goalDocument.get();
    if (!goalDocument.exists) {
      _goal = Goal();
    } else {
      _goal = Goal.fromMap(goalDocument.data() as Map<String, dynamic>);
    }

    QuerySnapshot<Map<String, dynamic>> query = await _appDocument
        .collection("Donations")
        .where("creator_id", isEqualTo: widget.creatorId)
        .orderBy("timestamp", descending: true)
        .get();

    if (query.docs.isEmpty) {
      return;
    }

    for (int i = 0; i < query.docs.length; i++) {
      Donation donation = Donation.fromMap(query.docs[i].data());
      user_model.User supporter = user_model.User();

      _kahwas += donation.kahwas!;

      if (!_supportersList.contains(donation.supporter_id)) {
        _supportersList.add(donation.supporter_id!);
      }

      if (donation.keep_private == false ||
          donation.creator_id == _user.uid ||
          donation.supporter_id == _user.uid) {
        DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
            await _appDocument
                .collection("Users")
                .doc(donation.supporter_id)
                .get();
        supporter = user_model.User.fromMap(
            documentSnapshot.data() as Map<String, dynamic>);
      }

      _donationSupporterList.insert(
          i,
          DonationSupporter(
            donation: donation,
            supporter: supporter,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        actions: [
          Tooltip(
            message: "Share",
            child: IconButton(
              onPressed: () => Share.share(
                  "${Statics.dynamicUrlPrefix}/${_userModel.link_id!}"),
              icon: const Icon(Icons.share_rounded),
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _runFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error getting data",
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: _creatorColor,
                    ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
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
                        backgroundColor: _creatorColor,
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
                          onTap: _user.uid != widget.creatorId ||
                                  _userModel.fans!.isEmpty
                              ? null
                              : () => Navigator.pushNamed(
                                    context,
                                    routeFansSupporters,
                                    arguments: FansSupportersArgs(
                                      title:
                                          "${_userModel.fans!.length} ${_userModel.fans!.length == 1 ? "Fan" : "Fans"}",
                                      list: _userModel.fans!,
                                    ),
                                  ),
                          child: CreatorCounterCard(
                            counter: _userModel.fans!.length,
                            title:
                                _userModel.fans!.length == 1 ? "Fan" : "Fans",
                          ),
                        ),
                        GestureDetector(
                          onTap: _user.uid != widget.creatorId ||
                                  _supportersList.isEmpty
                              ? null
                              : () => Navigator.pushNamed(
                                    context,
                                    routeFansSupporters,
                                    arguments: FansSupportersArgs(
                                      title:
                                          "${_supportersList.length} ${_supportersList.length == 1 ? "Supporter" : "Supporters"}",
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
                    _user.uid == widget.creatorId
                        ? Container()
                        : verticalSpace(),
                    _user.uid == widget.creatorId
                        ? Container()
                        : Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await Navigator.pushNamed(
                                      context,
                                      routeDonate,
                                      arguments: _userModel.id,
                                    );
                                    setState(() {});
                                  },
                                  icon: Image.asset(
                                    "assets/cup.png",
                                    width: 24,
                                  ),
                                  label: const Text("Buy a kahwa"),
                                ),
                              ),
                              horizontalSpace(width: 16),
                              GestureDetector(
                                onTap: () async {
                                  if (_userModel.fans!.contains(_user.uid)) {
                                    _userModel.fans!
                                        .removeWhere((id) => _user.uid == id);
                                  } else {
                                    _userModel.fans!.add(_user.uid);
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
                                        color: _creatorColor,
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
                                          color: _creatorColor,
                                        ),
                                        Text(
                                          "Fan",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall!
                                              .copyWith(
                                                color: _creatorColor,
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
                    if (_goal.title != null)
                      GoalCard(
                        goal: _goal,
                        deleted: (deleted) {
                          setState(() {
                            if (deleted) {
                              _goal = Goal();
                            }
                          });
                        },
                      )
                    else if (_goalDocument.id == _user.uid)
                      const AddGoalCard()
                    else
                      Container(),
                    verticalSpace(),
                    _userModel.about == null
                        ? Container()
                        : Text(
                            "About",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
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
                            moreStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontWeight: kBoldFontWeight,
                                  color: _creatorColor,
                                ),
                            trimExpandedText: "Show Less",
                            lessStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontWeight: kBoldFontWeight,
                                  color: _creatorColor,
                                ),
                          ),
                    _userModel.website == null
                        ? Container()
                        : verticalSpace(height: 16),
                    _userModel.website == null
                        ? Container()
                        : GestureDetector(
                            onTap: () async {
                              if (!await launchUrl(
                                Uri.parse("http://${_userModel.website}"),
                                mode: LaunchMode.externalApplication,
                              )) {
                                SnackBar snackBar = const SnackBar(
                                    content: Text("Cannot open link"));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.link_rounded),
                                horizontalSpace(),
                                Text(
                                  "${_userModel.website}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: _creatorColor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                    _userModel.website == null ? Container() : verticalSpace(),
                    _donationSupporterList.isEmpty
                        ? Container()
                        : Text(
                            "Recent Supporters",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  fontWeight: kSemiBoldFontWeight,
                                ),
                          ),
                    _donationSupporterList.isEmpty
                        ? Container()
                        : verticalSpace(height: 16),
                    ..._donationSupporterList.map((donationSupporter) => Column(
                          children: [
                            SupporterCard(
                              donationSupporter: donationSupporter,
                            ),
                            verticalSpace(height: 12),
                          ],
                        )),
                  ],
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
