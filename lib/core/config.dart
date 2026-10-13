import 'package:flutter/foundation.dart';

/// Build time configuration, set with `--dart-define=NAME=value`.
abstract final class AppConfig {
  /// Public address of the web app, used to build links to creator pages.
  static const _appUrl = String.fromEnvironment('APP_URL');

  /// Connect to the local Firebase emulators instead of the real project.
  static const useEmulators = bool.fromEnvironment('USE_EMULATORS');

  /// `dev` or `prod`, to choose the Firebase project of a web build.
  static const _firebaseEnv = String.fromEnvironment('FIREBASE_ENV');

  /// Whether this build talks to the production Firebase project.
  ///
  /// Release builds do. Everything else, such as `flutter run`, uses the
  /// development project, so everyday testing never touches real data.
  ///
  /// On the web, `--dart-define=FIREBASE_ENV=dev` builds a release that
  /// stays on development, for a test website. Android always follows the
  /// build type, because `google-services.json` is picked the same way in
  /// `android/app/build.gradle.kts` and the two have to agree.
  ///
  /// A constant, so a build only contains the configuration of one project.
  static const useProduction = !kIsWeb || _firebaseEnv == ''
      ? kReleaseMode
      : _firebaseEnv == 'prod';

  static const feedbackUrl = 'https://github.com/georges-ph/kahwa/issues';

  static String get appUrl {
    if (_appUrl.isNotEmpty) return _appUrl;
    if (kIsWeb) return Uri.base.origin;
    return '';
  }

  /// Link to share for the page of a creator: their username when they
  /// picked one, their id otherwise.
  static String creatorLink({required String id, String? username}) {
    return username == null ? '$appUrl/c/$id' : '$appUrl/$username';
  }
}
