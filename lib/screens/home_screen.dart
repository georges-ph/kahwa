// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/models/user.dart' as user_model;
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/routes.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/typography.dart';
import 'package:kahwa/widgets/creator_card.dart';
import 'package:kahwa/widgets/input_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  late User _user;
  late DocumentReference _appDocument;

  late Future<void> _runFuture;

  late user_model.User _userModel;
  late user_model.User creatorr;

  @override
  void initState() {
    super.initState();
    _user = _firebaseAuth.currentUser!;
    _appDocument = _firebaseFirestore.collection("kahwa").doc("AppCollections");
    _runFuture = _getData();
  }

  Future<void> _getData() async {
    DocumentSnapshot<Map<String, dynamic>> userDocument =
        await _appDocument.collection("Users").doc(_user.uid).get();
    _userModel =
        user_model.User.fromMap(userDocument.data() as Map<String, dynamic>);

    DocumentSnapshot<Map<String, dynamic>> creatorDoc = await _appDocument
        .collection("Users")
        .doc("dkC8yxYaKXTTZsDVR7MYpPNT8nE2")
        .get();

    creatorr =
        user_model.User.fromMap(creatorDoc.data() as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
            "Home"), // TODO: style this better, according to the design I made; otherwise - if it doesn't work - add it to the Column
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, routeSettings),
            icon: Icon(Icons.settings_rounded),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              routeCreator,
              arguments: _user.uid,
            ),
            child: CircleAvatar(
              backgroundColor: kBrownColor,
              backgroundImage:
                  _user.photoURL != null ? NetworkImage(_user.photoURL!) : null,
              child: _user.photoURL == null
                  ? Text(
                      getInitials(_user.displayName!),
                      style: TextStyle(
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(),
                InputText(
                  icon: Icons.search_rounded,
                  iconColor: kGreyColor,
                  hint: "Search creators",
                ),
                verticalSpace(),
                Text(
                  "Creators you are a fan of",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: kSemiBoldFontWeight,
                      ),
                ),
                verticalSpace(height: 8),
                CreatorCard(creator: creatorr),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
