import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Choices kept on the device: light or dark, and the language.
class AppSettings {
  const AppSettings({this.themeMode = ThemeMode.system, this.locale});

  final ThemeMode themeMode;

  /// Null follows the device.
  final Locale? locale;

  static const supportedLocales = [Locale('en'), Locale('fr'), Locale('ar')];

  /// Each language, written in itself.
  static const languageNames = {
    'en': 'English',
    'fr': 'Français',
    'ar': 'العربية',
  };
}

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Overridden in main'),
);

class SettingsNotifier extends Notifier<AppSettings> {
  static const _themeKey = 'theme_mode';
  static const _localeKey = 'locale';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final theme = ThemeMode.values
        .where((m) => m.name == prefs.getString(_themeKey))
        .firstOrNull;
    final locale = prefs.getString(_localeKey);
    return AppSettings(
      themeMode: theme ?? ThemeMode.system,
      locale: locale == null ? null : Locale(locale),
    );
  }

  void setThemeMode(ThemeMode mode) {
    _prefs.setString(_themeKey, mode.name);
    state = AppSettings(themeMode: mode, locale: state.locale);
  }

  void setLocale(Locale? locale) {
    if (locale == null) {
      _prefs.remove(_localeKey);
    } else {
      _prefs.setString(_localeKey, locale.languageCode);
    }
    state = AppSettings(themeMode: state.themeMode, locale: locale);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
