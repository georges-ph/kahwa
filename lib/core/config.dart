import 'package:flutter/foundation.dart';

/// Build time configuration, set with `--dart-define=NAME=value`.
abstract final class AppConfig {
  /// Public address of the web app, used to build links to creator pages.
  static const _appUrl = String.fromEnvironment('APP_URL');

  /// Connect to the local Firebase emulators instead of the real project.
  static const useEmulators = bool.fromEnvironment('USE_EMULATORS');

  /// Where the emulators answer. An Android emulator reaches this computer
  /// at `10.0.2.2`.
  static const emulatorHost = String.fromEnvironment(
    'EMULATOR_HOST',
    defaultValue: '127.0.0.1',
  );
  static const authEmulatorPort = int.fromEnvironment(
    'AUTH_EMULATOR_PORT',
    defaultValue: 9099,
  );
  static const firestoreEmulatorPort = int.fromEnvironment(
    'FIRESTORE_EMULATOR_PORT',
    defaultValue: 8080,
  );

  /// `dev` or `prod`, to choose the Firebase project of a build.
  static const _firebaseEnv = String.fromEnvironment('FIREBASE_ENV');

  /// Whether this build talks to the production Firebase project.
  ///
  /// Release builds do. Everything else, such as `flutter run`, uses the
  /// development project, so everyday testing never touches real data.
  ///
  /// `--dart-define=FIREBASE_ENV=dev` builds a release that stays on
  /// development: a test website, or an Android app that runs at full speed
  /// as "kahwa dev". On Android `android/app/build.gradle.kts` reads the same
  /// define to pick `google-services.json`, because the two have to agree.
  /// `FIREBASE_ENV=prod` only counts on the web.
  ///
  /// An emulator build never does, even in release mode, so it cannot reach
  /// production if something misses the emulators.
  ///
  /// A constant, so a build only contains the configuration of one project.
  static const useProduction =
      !useEmulators &&
      (_firebaseEnv == 'dev'
          ? false
          : kIsWeb && _firebaseEnv != ''
          ? _firebaseEnv == 'prod'
          : kReleaseMode);

  /// Two-step verification with an authenticator app. Off until the Firebase
  /// project is upgraded to Identity Platform with TOTP turned on: until then
  /// Firebase refuses it, so the app does not offer it.
  static const twoStepEnabled = false;

  static const feedbackUrl = 'https://github.com/georges-ph/kahwa/issues';
  static const sourceUrl = 'https://github.com/georges-ph/kahwa';

  /// Where the web app of each Firebase project is served. An app built
  /// without `APP_URL` (an APK, say) links to the site of its own project.
  static const _productionUrl = 'https://shtrilekahwa.web.app';
  static const _developmentUrl = 'https://shtrilekahwa-dev.web.app';

  static String get appUrl {
    if (_appUrl.isNotEmpty) return _appUrl;
    if (kIsWeb) return Uri.base.origin;
    return useProduction ? _productionUrl : _developmentUrl;
  }

  /// Link to share for the page of a creator: their username when they
  /// picked one, their id otherwise.
  static String creatorLink({required String id, String? username}) {
    return username == null ? '$appUrl/c/$id' : '$appUrl/$username';
  }
}
