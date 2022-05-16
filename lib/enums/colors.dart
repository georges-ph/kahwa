import 'dart:ui';

import 'package:kahwa/utils/colors.dart';

enum Colors { brown, pink, purple, cyan, green, yellow }

Color getColor(Colors colorEnum) {
  switch (colorEnum) {
    case Colors.brown:
      return kBrownColor;

    case Colors.pink:
      return kPinkColor;

    case Colors.purple:
      return kPurpleColor;

    case Colors.cyan:
      return kCyanColor;

    case Colors.green:
      return kGreenColor;

    case Colors.yellow:
      return kYellowColor;
  }
}
