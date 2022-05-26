import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/enums/colors.dart' as colors_enum;
import 'package:kahwa/models/goal.dart';

class Statics {
  static String userImage = "";
  static late PendingDynamicLinkData? initialLink;
  static late Goal goal;
  static String dynamicUrlPrefix = "https://shtrilekahwa.page.link";
  static Color creatorColor = colors_enum.getColor(colors_enum.Colors.brown);
}
