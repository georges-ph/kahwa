import 'package:flutter/material.dart';
import 'package:kahwa/core/colors.dart';

/// Accent color a creator picks for their page.
enum CreatorColor {
  brown(kBrownColor),
  pink(kPinkColor),
  purple(kPurpleColor),
  cyan(kCyanColor),
  green(kGreenColor),
  yellow(kYellowColor);

  const CreatorColor(this.color);

  final Color color;

  static CreatorColor fromName(String? name) {
    return CreatorColor.values.firstWhere(
      (color) => color.name == name,
      orElse: () => CreatorColor.brown,
    );
  }
}
