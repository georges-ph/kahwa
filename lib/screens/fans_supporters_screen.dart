import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/models/fan_supporter.dart';
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/routes.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/typography.dart';

class FansSupportersScreen extends StatefulWidget {
  const FansSupportersScreen({
    Key? key,
    required this.title,
    required this.list,
  }) : super(key: key);

  final String title;
  final List<String> list;

  @override
  State<FansSupportersScreen> createState() => _FansSupportersScreenState();
}

class _FansSupportersScreenState extends State<FansSupportersScreen> {
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection("kahwa")
      .doc("AppCollections")
      .collection("Users");

  final List<FanSupporter> _list = [];

  late Future<void> _runFuture;

  @override
  void initState() {
    super.initState();
    _runFuture = _getData();
  }

  Future<void> _getData() async {
    for (var fanId in widget.list) {
      DocumentSnapshot document = await _usersCollection.doc(fanId).get();
      FanSupporter fan =
          FanSupporter.fromMap(document.data() as Map<String, dynamic>);
      _list.add(fan);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: widget.list.length,
              separatorBuilder: (BuildContext context, int index) {
                return verticalSpace(height: 16);
              },
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  onTap: () => Navigator.pushNamed(
                    context,
                    routeCreator,
                    arguments: _list.elementAt(index).id,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: kBrownColor,
                    backgroundImage: _list.elementAt(index).image != null
                        ? NetworkImage(_list.elementAt(index).image!)
                        : null,
                    child: _list.elementAt(index).image == null
                        ? Text(
                            getInitials(_list.elementAt(index).name!),
                            style: const TextStyle(
                              color: kWhiteColor,
                            ),
                          )
                        : null,
                  ),
                  title: Text(_list.elementAt(index).name!),
                );
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
