import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/screens/home_screen.dart';
import 'package:kahwa/screens/login_screen.dart';
import 'package:kahwa/utils/routes.dart';
import 'package:kahwa/utils/statics.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  // void _checkDynamicLink(PendingDynamicLinkData? deepLink) async {
  //   deepLink = await FirebaseDynamicLinks.instance.getInitialLink();
  // }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    // PendingDynamicLinkData? deepLink;
    // _checkDynamicLink(deepLink);

    return StreamBuilder<User?>(
      stream: _firebaseAuth.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User user = _firebaseAuth.currentUser!;
          if (user.photoURL != null) {
            Statics.userImage = user.photoURL!;
          }

          FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
            Navigator.pushNamed(
              context,
              routeCreator,
              arguments: dynamicLinkData.link
                  .toString()
                  .split("https://kahwa.page.link/")[1],
            );
          });

          if (Statics.initialLink != null) {
            Future.delayed(
                Duration.zero,
                () => Navigator.pushNamed(
                      context,
                      routeCreator,
                      arguments: Statics.initialLink!.link
                          .toString()
                          .split("https://kahwa.page.link/")[1],
                    ));
          }

          return const HomeScreen();
        } else {
          return const LogInScreen();
        }
      },
    );
  }
}
