// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/models/user.dart' as user_model;
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/routes.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/typography.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Home"),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, routeSettings),
            icon: Icon(Icons.settings_rounded),
          ),
          CircleAvatar(
            backgroundColor: kRedColor,
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
                CreatorCard(user: _user),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class CreatorCard extends StatelessWidget {
  const CreatorCard({
    Key? key,
    required User user,
  })  : _user = user,
        super(key: key);

  final User _user;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox.square(
                dimension: 64,
                child: _user.photoURL != null
                    ? Image(
                        image: NetworkImage(
                            "https://images.unsplash.com/photo-1650038132376-5bb0e549e19f?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=685&q=80"),
                        fit: BoxFit.fitWidth,
                      )
                    : ColoredBox(
                        color: kRedColor,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            getInitials(_user.displayName!),
                            style: TextStyle(
                              color: kWhiteColor,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            horizontalSpace(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "David Beckham",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: kSemiBoldFontWeight,
                      ),
                ),
                Row(
                  children: [
                    Image(
                      image: AssetImage("assets/fenjen.png"),
                      width: 24,
                    ),
                    horizontalSpace(width: 8),
                    Text(
                      "70 kahwas received",
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.favorite_border_rounded),
                    horizontalSpace(width: 8),
                    Text("123 Fans"),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
