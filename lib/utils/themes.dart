import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kahwa/utils/colors.dart';

ThemeData lightTheme(BuildContext context) {
  return ThemeData(
    colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: kRedColor,
        ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.all(kRedColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(16),
        textStyle: Theme.of(context).textTheme.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.all(kRedColor),
    ),
    textTheme: GoogleFonts.manropeTextTheme(
      Theme.of(context).textTheme,
    ),
  );
}
