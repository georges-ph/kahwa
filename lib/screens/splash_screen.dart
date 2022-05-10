import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/screens/home_screen.dart';
import 'package:kahwa/screens/login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  // void _checkDynamicLink(PendingDynamicLinkData? deepLink) async {
  //   deepLink = await FirebaseDynamicLinks.instance.getInitialLink();
  // }

  @override
  Widget build(BuildContext context) {
    // PendingDynamicLinkData? deepLink;
    // _checkDynamicLink(deepLink);

    // FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
    //   Navigator.pushNamed(context, routeDonate,
    //       arguments: dynamicLinkData.link
    //           .toString()
    //           .split("https://kahwa.page.link/")[1]);
    // });

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // if (deepLink != null) {
          //   Uri uri = deepLink.link;
          //   print("uri: $uri");
          //   String creatorId =
          //       uri.toString().split("https://kahwa.page.link/")[1];
          //   return DonateScreen(creatorId: creatorId);
          // }
          return const HomeScreen();
        } else {
          return const LogInScreen();
        }
      },
    );
  }
}
