import 'package:flutter/material.dart';

SizedBox verticalSpace({double? height}) {
  return SizedBox(
    height: height ?? 24,
  );
}

SizedBox horizontalSpace({double? width}) {
  return SizedBox(
    width: width ?? 8,
  );
}
