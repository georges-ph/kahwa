/// Rules for the handle a creator can pick for the address of their page.
abstract final class Username {
  static const minLength = 3;
  static const maxLength = 20;

  static final _pattern = RegExp('^[a-z0-9_]{$minLength,$maxLength}\$');

  /// Words that are, or could become, addresses of the app itself.
  static const _reserved = {
    'admin',
    'assets',
    'canvaskit',
    'goal',
    'help',
    'home',
    'icons',
    'kahwa',
    'login',
    'settings',
    'signin',
    'signup',
    'support',
  };

  /// What users type, tidied up: no spaces, no leading @, lower case.
  static String normalize(String input) {
    final trimmed = input.trim().toLowerCase();
    return trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;
  }

  /// Why [username] cannot be used, or null when it is fine.
  static String? validate(String username) {
    if (username.length < minLength || username.length > maxLength) {
      return 'Use $minLength to $maxLength characters';
    }
    if (!_pattern.hasMatch(username)) {
      return 'Use only letters, numbers and underscores';
    }
    if (_reserved.contains(username)) return 'This username is not available';
    return null;
  }
}
