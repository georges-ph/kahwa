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
  // late user_model.User creatorr;

  List<user_model.User> _creators = [];

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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Tooltip(
            message: "Settings",
            child: IconButton(
              onPressed: () => Navigator.pushNamed(context, routeSettings),
              icon: Icon(Icons.settings_rounded),
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
            return SingleChildScrollView(
              padding: EdgeInsets.all(24),
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Home".toUpperCase(),
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  verticalSpace(),
                  Text(
                    "Creators you are a fan of",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: kSemiBoldFontWeight,
                    ),
                  ),
                  verticalSpace(height: 16),
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
