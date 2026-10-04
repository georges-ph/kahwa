import 'package:flutter/material.dart';

const kBrownColor = Color(0xFF630913);
const kGreyColor = Color(0xFF808080);
const kWhiteColor = Colors.white;
const kBlackColor = Colors.black;

const kPinkColor = Color(0xFFBB0D98);
const kPurpleColor = Color(0xFF5F5AEA);
const kCyanColor = Color(0xFF38CAE1);
const kGreenColor = Color(0xFF3CF078);
const kYellowColor = Color(0xFFFCF655);

/// Background of inputs and neutral cards.
final kFillColor = kGreyColor.withValues(alpha: 0.1);

/// Black or white, whichever reads better on top of [background].
Color foregroundOn(Color background) {
  return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
      ? kWhiteColor
      : kBlackColor;
}
