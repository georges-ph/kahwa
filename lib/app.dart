import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kahwa/l10n/app_localizations.dart';
import 'package:kahwa/router.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/state/settings.dart';
import 'package:kahwa/theme/app_theme.dart';

class KahwaApp extends ConsumerWidget {
  const KahwaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);
    // This device in the user's list, and signing out when told to.
    ref.watch(deviceSessionProvider);
    final arabic = settings.locale?.languageCode == 'ar';

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => 'kahwa',
      theme: buildTheme(brightness: Brightness.light, arabic: arabic),
      darkTheme: buildTheme(brightness: Brightness.dark, arabic: arabic),
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: AppSettings.supportedLocales,
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        final theme = Theme.of(context);
        // The device language can be Arabic while no choice was saved.
        final isArabic = Localizations.localeOf(context).languageCode == 'ar';
        final themed = isArabic && !arabic
            ? Theme(
                data: buildTheme(brightness: theme.brightness, arabic: true),
                child: child!,
              )
            : child!;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle(theme.brightness, theme.scaffoldBackgroundColor),
          child: themed,
        );
      },
    );
  }
}
