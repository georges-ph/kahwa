import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/typography.dart';

ThemeData lightTheme(BuildContext context) {
  return ThemeData(
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(
        color: kBlackColor,
      ),
      foregroundColor: kBlackColor,
      actionsIconTheme: IconThemeData(
        color: kGreyColor,
      ),
    ),
    colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: kBrownColor,
        ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.all(kBrownColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    chipTheme: ChipThemeData(
      selectedColor: kBrownColor.withOpacity(0.8),
      labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: kRegularFontWeight,
            color: kWhiteColor,
          ),
      backgroundColor: kBrownColor.withOpacity(0.2),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(16),
        textStyle: Theme.of(context).textTheme.bodyLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.all(kBrownColor),
    ),
    textTheme: GoogleFonts.manropeTextTheme(
      Theme.of(context).textTheme,
    ).copyWith(
      headlineLarge: GoogleFonts.manrope(
        fontWeight: kExtraBoldFontWeight,
        color: kBlackColor,
      ),
      // titleLarge: GoogleFonts.manrope(),
      // titleMedium: GoogleFonts.manrope(),
      // titleSmall: GoogleFonts.manrope(),
      // labelLarge: GoogleFonts.manrope(),
      // labelMedium: GoogleFonts.manrope(),
      // bodyLarge: GoogleFonts.manrope(),
      // bodyMedium: GoogleFonts.manrope(),
      // bodySmall: GoogleFonts.manrope(),
      // displaySmall: GoogleFonts.manrope(),
    ),
  );
}
