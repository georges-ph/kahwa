// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/models/supporter.dart';
import 'package:kahwa/utils/sizes.dart';

class FansSupportersScreen extends StatefulWidget {
  const FansSupportersScreen({
    Key? key,
    required this.title,
    required this.list,
  }) : super(key: key);

  final String title;
  final List<Supporter> list;

  @override
  State<FansSupportersScreen> createState() => _FansSupportersScreenState();
}

class _FansSupportersScreenState extends State<FansSupportersScreen> {

   final User _user = FirebaseAuth.instance.currentUser!;
   final DocumentReference _appDocument =
      FirebaseFirestore.instance.collection("kahwa").doc("AppCollections");

  @override
  void initState() {
    super.initState();
    _getList();
  }

  void _getList() async {
    DocumentSnapshot<Map<String, dynamic>> userDocument =
        await _appDocument.collection("Users").doc(_user.uid).get();

    // _userModel =
    //     user_model.User.fromMap(userDocument.data() as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.list.length} ${widget.title}"),
      ),
      body: ListView.separated(
        itemCount: widget.list.length,
        separatorBuilder: (BuildContext context, int index) {
          return verticalSpace(height: 16);
        },
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            // leading: CircleAvatar(
            //   backgroundImage: _userModel.image != null
            //       ? NetworkImage(_userModel.image!)
            //       : null,
            //   backgroundColor: _userModel.image == null ? kRedColor : null,
            //   child: _userModel.image == null
            //       ? Text(
            //           getInitials(_userModel.name!),
            //           style: Theme.of(context).textTheme.displaySmall!.copyWith(
            //                 color: kWhiteColor,
            //               ),
            //         )
            //       : null,
            // ),
            title: Text(widget.list.elementAt(index).name!),
          );
        },
      ),
    );
  }
}
