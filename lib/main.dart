import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kahwa/app.dart';
import 'package:kahwa/core/config.dart';
import 'package:kahwa/firebase_options_dev.dart' as dev;
import 'package:kahwa/firebase_options_prod.dart' as prod;
import 'package:kahwa/state/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  // Keep the address bar in step with pages opened from inside the app, so
  // the address of a creator page can be copied and shared.
  GoRouter.optionURLReflectsImperativeAPIs = true;
  timeago.setLocaleMessages('ar', timeago.ArMessages());
  timeago.setLocaleMessages('fr', timeago.FrMessages());

  final (_, prefs) = await (
    Firebase.initializeApp(
      options: AppConfig.useProduction
          ? prod.DefaultFirebaseOptions.currentPlatform
          : dev.DefaultFirebaseOptions.currentPlatform,
    ),
    SharedPreferences.getInstance(),
  ).wait;

  if (AppConfig.useEmulators) {
    /// `firebase emulators:start --only auth,firestore`
    const host = AppConfig.emulatorHost;
    await FirebaseAuth.instance.useAuthEmulator(
      host,
      AppConfig.authEmulatorPort,
    );
    // A session kept in the browser is restored before the emulator is
    // connected, and sends the next sign in to the real project. Keeping
    // none means a reload signs out instead.
    if (kIsWeb) await FirebaseAuth.instance.setPersistence(Persistence.NONE);
    FirebaseFirestore.instance.useFirestoreEmulator(
      host,
      AppConfig.firestoreEmulatorPort,
    );
  }

  if (!kIsWeb) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    // Reads the Google client from the google-services.json of this build,
    // which is of the same Firebase project as the options above.
    await GoogleSignIn.instance.initialize();
  }

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      observers: [if (!kReleaseMode) _LogErrors()],
      child: const KahwaApp(),
    ),
  );
}

/// Prints what failed to load, outside release builds.
class _LogErrors extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (newValue case AsyncError(:final error, :final stackTrace)) {
      final name = provider.name ?? provider.runtimeType;
      debugPrint('$name failed: $error');
      debugPrint('$stackTrace');
    }
  }
}
