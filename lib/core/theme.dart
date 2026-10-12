import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kahwa/core/colors.dart';

/// Theme of the app. Creator pages pass the color the creator picked as
/// [primary] so the whole page takes their accent.
ThemeData appTheme({Color primary = kBrownColor}) {
  final onPrimary = foregroundOn(primary);
  final colorScheme = ColorScheme.fromSeed(seedColor: primary).copyWith(
    primary: primary,
    onPrimary: onPrimary,
    surface: kWhiteColor,
    onSurface: kBlackColor,
    surfaceTint: Colors.transparent,
    surfaceContainerLow: kWhiteColor,
  );
  final textTheme = GoogleFonts.manropeTextTheme().copyWith(
    headlineLarge: GoogleFonts.manrope(
      fontWeight: FontWeight.w800,
      color: kBlackColor,
    ),
  );
  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  );

  return ThemeData(
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: kWhiteColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: kBlackColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      actionsIconTheme: IconThemeData(color: kGreyColor),
    ),
    cardTheme: CardThemeData(
      color: kWhiteColor,
      elevation: 1,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        minimumSize: const Size(64, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: textTheme.bodyLarge,
        shape: buttonShape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kBlackColor,
        minimumSize: const Size(64, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: textTheme.bodyLarge,
        side: BorderSide(color: primary),
        shape: buttonShape,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kFillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      errorMaxLines: 3,
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    chipTheme: ChipThemeData(
      showCheckmark: false,
      side: BorderSide.none,
      backgroundColor: primary.withValues(alpha: 0.15),
      selectedColor: primary,
      labelStyle: textTheme.bodyLarge?.copyWith(color: kBlackColor),
      secondaryLabelStyle: textTheme.bodyLarge?.copyWith(color: onPrimary),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: kWhiteColor),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
