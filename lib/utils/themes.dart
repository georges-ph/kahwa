import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/typography.dart';

ThemeData lightTheme(BuildContext context) {
  return ThemeData(
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: kBlackColor,
          ),
      iconTheme: const IconThemeData(
        color: kBlackColor,
      ),
      actionsIconTheme: const IconThemeData(
        color: kGreyColor,
      ),
    ),
    colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: kRedColor,
        ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.all(kRedColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    chipTheme: ChipThemeData(
      selectedColor: kRedColor.withOpacity(0.8),
      labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: kRegularFontWeight,
            color: kWhiteColor,
          ),
      backgroundColor: kRedColor.withOpacity(0.2),
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
