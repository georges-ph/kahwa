import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kahwa/theme/palette.dart';

/// Colors the Material scheme has no good slot for.
@immutable
class KahwaColors extends ThemeExtension<KahwaColors> {
  const KahwaColors({
    required this.page,
    required this.card,
    required this.subtle,
    required this.border,
    required this.muted,
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.danger,
    required this.dangerContainer,
    required this.dangerFill,
  });

  /// Background of the page, a step below [card].
  final Color page;
  final Color card;

  /// Fill of inputs, chips and quiet tiles.
  final Color subtle;
  final Color border;

  /// Secondary text.
  final Color muted;
  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;
  final Color danger;
  final Color dangerContainer;

  /// Background of red buttons, under white text.
  final Color dangerFill;

  static const light = KahwaColors(
    page: Color(0xFFF6F3F1),
    card: Colors.white,
    subtle: Color(0xFFF0ECEA),
    border: Color(0xFFE8E2DE),
    muted: Color(0xFF6E6670),
    success: Color(0xFF16794C),
    successContainer: Color(0xFFDDF3E6),
    warning: Color(0xFF8A5A00),
    warningContainer: Color(0xFFFCEFD2),
    danger: Color(0xFFB3261E),
    dangerContainer: Color(0xFFFCE4E1),
    dangerFill: Color(0xFFB3261E),
  );

  static const dark = KahwaColors(
    page: Color(0xFF0F0D10),
    card: Color(0xFF1A171B),
    subtle: Color(0xFF252126),
    border: Color(0xFF2F2A30),
    muted: Color(0xFFA79EA8),
    success: Color(0xFF6FD49B),
    successContainer: Color(0xFF173626),
    warning: Color(0xFFF2C46B),
    warningContainer: Color(0xFF3A2D12),
    // The coffee reds of the dark accent (see [accentFor] and [fillFor]),
    // not a salmon red.
    danger: Color(0xFFD8605A),
    dangerContainer: Color(0xFF451B18),
    dangerFill: Color(0xFFA83C38),
  );

  @override
  KahwaColors copyWith() => this;

  @override
  KahwaColors lerp(KahwaColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return KahwaColors(
      page: mix(page, other.page),
      card: mix(card, other.card),
      subtle: mix(subtle, other.subtle),
      border: mix(border, other.border),
      muted: mix(muted, other.muted),
      success: mix(success, other.success),
      successContainer: mix(successContainer, other.successContainer),
      warning: mix(warning, other.warning),
      warningContainer: mix(warningContainer, other.warningContainer),
      danger: mix(danger, other.danger),
      dangerContainer: mix(dangerContainer, other.dangerContainer),
      dangerFill: mix(dangerFill, other.dangerFill),
    );
  }
}

extension KahwaTheme on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  KahwaColors get kahwa => Theme.of(this).extension<KahwaColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

/// Corner radii used across the app.
abstract final class Radii {
  static const card = 24.0;
  static const tile = 18.0;
  static const field = 16.0;
}

const _latinFont = 'Manrope';
const _arabicFont = 'PlexArabic';

/// The theme of the app in [brightness]. Creator pages pass the color the
/// creator picked as [accent], so the whole page takes it.
ThemeData buildTheme({
  required Brightness brightness,
  Color accent = Brand.maroon,
  bool arabic = false,
}) {
  final isDark = brightness == Brightness.dark;
  final tokens = isDark ? KahwaColors.dark : KahwaColors.light;
  final primary = fillFor(accent, brightness);
  // Text and links: lighter than the buttons on a dark page, to be read.
  final textAccent = accentFor(accent, brightness);
  final onPrimary = foregroundOn(primary);
  final foreground = isDark ? const Color(0xFFF4EFF2) : const Color(0xFF17141A);

  final scheme = ColorScheme.fromSeed(seedColor: accent, brightness: brightness)
      .copyWith(
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: Color.alphaBlend(
          primary.withValues(alpha: isDark ? 0.22 : 0.12),
          tokens.card,
        ),
        onPrimaryContainer: isDark ? textAccent : accent,
        // Tonal buttons: the same tint as the primary container, not the
        // light brown Material makes up from the seed.
        secondaryContainer: Color.alphaBlend(
          primary.withValues(alpha: isDark ? 0.28 : 0.14),
          tokens.card,
        ),
        onSecondaryContainer: isDark ? foreground : accent,
        surface: tokens.card,
        onSurface: foreground,
        onSurfaceVariant: tokens.muted,
        surfaceTint: Colors.transparent,
        surfaceContainerLowest: tokens.card,
        surfaceContainerLow: tokens.card,
        surfaceContainer: tokens.card,
        surfaceContainerHigh: tokens.card,
        surfaceContainerHighest: tokens.subtle,
        outline: tokens.border,
        outlineVariant: tokens.border,
        error: tokens.danger,
      );

  final family = arabic ? _arabicFont : _latinFont;
  final fallback = [arabic ? _latinFont : _arabicFont];
  final base =
      (isDark
              ? Typography.material2021().white
              : Typography.material2021().black)
          .apply(
            fontFamily: family,
            fontFamilyFallback: fallback,
            bodyColor: foreground,
            displayColor: foreground,
          );
  TextStyle? heavy(TextStyle? style, [double? spacing]) => style?.copyWith(
    fontWeight: FontWeight.w800,
    letterSpacing: arabic ? 0 : spacing,
  );
  final textTheme = base.copyWith(
    displaySmall: heavy(base.displaySmall, -1),
    headlineLarge: heavy(base.headlineLarge, -0.8),
    headlineMedium: heavy(base.headlineMedium, -0.6),
    headlineSmall: heavy(base.headlineSmall, -0.4),
    titleLarge: heavy(base.titleLarge, -0.2),
    titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w700),
  );

  const pill = StadiumBorder();
  const buttonSize = Size(64, 52);
  final buttonText = textTheme.labelLarge?.copyWith(fontSize: 15);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    textTheme: textTheme,
    fontFamily: family,
    fontFamilyFallback: fallback,
    scaffoldBackgroundColor: tokens.page,
    canvasColor: tokens.page,
    dividerColor: tokens.border,
    splashFactory: InkSparkle.splashFactory,
    extensions: [tokens],
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.page,
      foregroundColor: foreground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
      systemOverlayStyle: overlayStyle(brightness, tokens.page),
    ),
    cardTheme: CardThemeData(
      color: tokens.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.card),
        side: BorderSide(color: tokens.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: buttonSize,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: pill,
        textStyle: buttonText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: buttonSize,
        shape: pill,
        textStyle: buttonText,
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: buttonSize,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: pill,
        foregroundColor: foreground,
        side: BorderSide(color: tokens.border, width: 1.5),
        textStyle: buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: pill,
        textStyle: buttonText,
        foregroundColor: textAccent,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: foreground),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tokens.subtle,
      hintStyle: TextStyle(color: tokens.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.field),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.field),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.field),
        borderSide: BorderSide(color: tokens.danger, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.field),
        borderSide: BorderSide(color: tokens.danger, width: 1.5),
      ),
      errorMaxLines: 3,
    ),
    chipTheme: ChipThemeData(
      showCheckmark: false,
      side: BorderSide.none,
      shape: pill,
      backgroundColor: tokens.subtle,
      selectedColor: primary,
      labelStyle: textTheme.labelLarge?.copyWith(color: foreground),
      secondaryLabelStyle: textTheme.labelLarge?.copyWith(color: onPrimary),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        foregroundColor: textAccent,
        selectedBackgroundColor: primary,
        selectedForegroundColor: onPrimary,
        side: BorderSide(color: tokens.border),
        shape: pill,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: tokens.card,
      indicatorColor: primary.withValues(alpha: isDark ? 0.24 : 0.12),
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStatePropertyAll(
        textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: tokens.page,
      indicatorColor: primary.withValues(alpha: isDark ? 0.24 : 0.12),
      selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: foreground,
      ),
      unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
        color: tokens.muted,
      ),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.tile),
      ),
      iconColor: foreground,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: tokens.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.card),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: tokens.card,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: foreground,
      unselectedLabelColor: tokens.muted,
      indicatorColor: primary,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: tokens.border,
      labelStyle: textTheme.titleSmall,
      unselectedLabelStyle: textTheme.titleSmall,
    ),
    switchTheme: SwitchThemeData(
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: tokens.subtle,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

/// Status and navigation bar icons that read on [background].
SystemUiOverlayStyle overlayStyle(Brightness brightness, Color background) {
  final isDark = brightness == Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    statusBarBrightness: brightness,
    systemNavigationBarColor: background,
    systemNavigationBarIconBrightness: isDark
        ? Brightness.light
        : Brightness.dark,
  );
}
