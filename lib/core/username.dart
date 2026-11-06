/// Rules for the handle a creator picks for the address of their page.
abstract final class Username {
  static const minLength = 3;
  static const maxLength = 20;

  static final _pattern = RegExp('^[a-z0-9_]{$minLength,$maxLength}\$');

  /// Words that are, or could become, addresses of the app itself.
  static const _reserved = {
    'activity',
    'admin',
    'assets',
    'c',
    'canvaskit',
    'explore',
    'forgot-password',
    'help',
    'home',
    'icons',
    'kahwa',
    'login',
    'me',
    'onboarding',
    'settings',
    'signin',
    'signup',
    'support',
    'wallet',
    'welcome',
  };

  /// What users type, tidied up: no spaces, no leading @, lower case.
  static String normalize(String input) {
    final trimmed = input.trim().toLowerCase();
    return trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;
  }

  /// Why [username] cannot be used, or null when it is fine.
  static UsernameProblem? validate(String username) {
    if (username.length < minLength || username.length > maxLength) {
      return UsernameProblem.length;
    }
    if (!_pattern.hasMatch(username)) return UsernameProblem.characters;
    if (_reserved.contains(username)) return UsernameProblem.reserved;
    return null;
  }
}

enum UsernameProblem { length, characters, reserved, taken }
