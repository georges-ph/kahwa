import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  if (kDebugMode) {
    const host = "127.0.0.1";
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseDatabase.instance.useDatabaseEmulator(host, 9000);
    await FirebaseStorage.instance.useStorageEmulator(host, 9199);
  }

  if (!kIsWeb) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    // Statics.initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

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
