import 'package:flutter/material.dart';

String getInitials(String userName) {
  List<String> names = userName.split(" ");
  String initials = "";
  names.forEach((element) {
    initials += element.characters.first;
  });
  return initials;
}
