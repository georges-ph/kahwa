import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/screens/home_screen.dart';
import 'package:kahwa/screens/login_screen.dart';
import 'package:kahwa/utils/routes.dart';
import 'package:kahwa/utils/statics.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

    return StreamBuilder<User?>(
      stream: _firebaseAuth.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User user = _firebaseAuth.currentUser!;
          if (user.photoURL != null) {
            Statics.userImage = user.photoURL!;
          }

          FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
            Uri uri = dynamicLinkData.link;
            final queryParams = uri.queryParameters;
            if (queryParams.isNotEmpty) {
              String creatorId = queryParams["id"]!;
              Navigator.pushNamed(
                context,
                routeCreator,
                arguments: creatorId,
              );
            }
          });

          if (Statics.initialLink != null) {
            Future.delayed(Duration.zero, () {
              Uri uri = Statics.initialLink!.link;
              final queryParams = uri.queryParameters;
              if (queryParams.isNotEmpty) {
                String creatorId = queryParams["id"]!;
                Navigator.pushNamed(
                  context,
                  routeCreator,
                  arguments: creatorId,
                );
              }
            });
          }

          return const HomeScreen();
        } else {
          return const LogInScreen();
        }
      },
    );
  }
}
