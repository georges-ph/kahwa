import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:kahwa/models/goal.dart';

class Statics {
  static String userImage = "";
  static late PendingDynamicLinkData? initialLink;
  static late Goal goal;
  static String dynamicUrlPrefix = "https://shtrile1kahwa.page.link";
}
