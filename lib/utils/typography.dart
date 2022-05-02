import 'package:flutter/material.dart';

const kThinFontWeight = FontWeight.w100;
const kExtraLightFontWeight = FontWeight.w200;
const kLightFontWeight = FontWeight.w300;
const kRegularFontWeight = FontWeight.w400;
const kMediumFontWeight = FontWeight.w500;
const kSemiBoldFontWeight = FontWeight.w600;
const kBoldFontWeight = FontWeight.w700;
const kExtraBoldFontWeight = FontWeight.w800;
const kBlackFontWeight = FontWeight.w900;

String getInitials(String userName) {
  List<String> names = userName.split(" ");
  String initials = "";
  names.forEach((element) {
    initials += element.characters.first;
  });
  return initials;
}
