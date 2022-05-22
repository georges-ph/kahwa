import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kahwa/models/user.dart' as user_model;
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/routes.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/statics.dart';
import 'package:kahwa/utils/typography.dart';
import 'package:kahwa/widgets/creator_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Size _screenSize;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  late User _user;
  late DocumentReference _appDocument;

  late Future<void> _runFuture;

  final List<user_model.User> _creators = [];

  @override
  void initState() {
    super.initState();
    _user = _firebaseAuth.currentUser!;
    _appDocument = _firebaseFirestore.collection("kahwa").doc("AppCollections");
    _runFuture = _getData();
  }

  Future<void> _getData() async {
    QuerySnapshot querySnapshot = await _appDocument
        .collection("Users")
        .where("fans", arrayContains: _user.uid)
        .get();
    querySnapshot.docs.forEach((document) {
      _creators.add(
          user_model.User.fromMap(document.data() as Map<String, dynamic>));
    });
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Tooltip(
            message: "Settings",
            child: IconButton(
              onPressed: () async {
                await Navigator.pushNamed(context, routeSettings);
                setState(() {});
              },
              icon: const Icon(Icons.settings_rounded),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              routeCreator,
              arguments: _user.uid,
            ),
            child: CircleAvatar(
              backgroundColor: kBrownColor,
              backgroundImage: Statics.userImage.isNotEmpty
                  ? NetworkImage(Statics.userImage)
                  : null,
              child: Statics.userImage.isEmpty
                  ? Text(
                      getInitials(_user.displayName!),
                      style: const TextStyle(
                        color: kWhiteColor,
                      ),
                      // style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      //       color: kWhiteColor,
                      //     ),
                    )
                  : null,
            ),
          ),
          horizontalSpace(),
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
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Home".toUpperCase(),
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  verticalSpace(),
                  _creators.isNotEmpty
                      ? Container()
                      : Align(
                          child: SizedBox(
                            width: _screenSize.width * 0.7,
                            child: SvgPicture.asset(
                              "assets/undraw_not_found.svg",
                              height: _screenSize.width * 0.8,
                            ),
                          ),
                        ),
                  _creators.isNotEmpty
                      ? Container()
                      : Align(
                          alignment: Alignment.center,
                          child: Text(
                            "You are not a fan of any creator yet",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                  _creators.isEmpty
                      ? Container()
                      : Text(
                          "Creators you are a fan of",
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontWeight: kSemiBoldFontWeight,
                                  ),
                        ),
                  _creators.isEmpty ? Container() : verticalSpace(height: 16),
                  ..._creators.map(
                    (user) => Column(
                      children: [
                        CreatorCard(creator: user),
                        verticalSpace(height: 12),
                      ],
                    ),
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
