import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/firebase_options.dart';
import 'package:kahwa/utils/routes.dart';
import 'package:kahwa/utils/statics.dart';
import 'package:kahwa/utils/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    Statics.initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "kahwa",
      theme: lightTheme(context),
      initialRoute: routeSplash,
      routes: routes,
      onGenerateRoute: onGenerateRoute,
    );
  }
}
