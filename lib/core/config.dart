import 'package:flutter/foundation.dart';

/// Build time configuration, set with `--dart-define=NAME=value`.
abstract final class AppConfig {
  /// Public address of the web app, used to build links to creator pages.
  static const _appUrl = String.fromEnvironment('APP_URL');

  /// Connect to the local Firebase emulators instead of the real project.
  static const useEmulators = bool.fromEnvironment('USE_EMULATORS');

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
