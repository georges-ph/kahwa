import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/firebase_options.dart';
import 'package:kahwa/utils/routes.dart';
import 'package:kahwa/utils/themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
