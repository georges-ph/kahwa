// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:kahwa/models/fan_supporter.dart';
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/routes.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/typography.dart';

class FansSupportersScreen extends StatelessWidget {
  const FansSupportersScreen({
    Key? key,
    required this.title,
    required this.list,
  }) : super(key: key);

  final String title;
  final List<FanSupporter> list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.separated(
        itemCount: list.length,
        separatorBuilder: (BuildContext context, int index) {
          return verticalSpace(height: 16);
        },
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            onTap: () => Navigator.pushNamed(
              context,
              routeCreator,
              arguments: list.elementAt(index).id,
            ),
            leading: CircleAvatar(
              backgroundColor: kRedColor,
              backgroundImage: list.elementAt(index).image != null
                  ? NetworkImage(list.elementAt(index).image!)
                  : null,
              child: list.elementAt(index).image == null
                  ? Text(
                      getInitials(list.elementAt(index).name!),
                      style: TextStyle(
                        color: kWhiteColor,
                      ),
                    )
                  : null,
            ),
            title: Text(list.elementAt(index).name!),
          );
        },
      ),
    );
  }
}
