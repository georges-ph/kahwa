import 'package:flutter/material.dart';

/// kahwa's own colors.
abstract final class Brand {
  /// The maroon of the kahwa cup, the identity of the app.
  static const maroon = Color(0xFF7B1424);

  static const cream = Color(0xFFFBF5EC);
}

/// Colors a creator can give their page. The first is kahwa's maroon.
const creatorColors = <Color>[
  Color(0xFF7B1424), // maroon
  Color(0xFFC2185B), // ruby
  Color(0xFFE2583E), // coral
  Color(0xFFDB8A0B), // amber
  Color(0xFF5E8C1F), // olive
  Color(0xFF0F8060), // emerald
  Color(0xFF0E7C86), // teal
  Color(0xFF1E7BD8), // sky
  Color(0xFF4F46E5), // indigo
  Color(0xFF7C3AED), // violet
  Color(0xFF9D3C8F), // plum
  Color(0xFF3A3F4B), // graphite
];

/// Emojis a user can pick as their avatar, since kahwa has no picture
/// uploads.
const avatarEmojis = <String>[
  '☕', '🎨', '🎵', '🎸', '🎤', '📷', '🎬', '✍️', '📚', '🎮', //
  '💻', '🎙️', '🍳', '🧁', '🌿', '🌊', '⛰️', '🌙', '⭐', '🔥', //
  '🐱', '🐶', '🦊', '🐢', '🦋', '🌸', '🍋', '🫒', '🌲', '⚽', //
];

/// Black or white, whichever reads better on top of [background].
Color foregroundOn(Color background) {
  return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
      ? Colors.white
      : const Color(0xFF17141A);
}

/// [color] made light enough to read as text or a button on a dark page.
Color liftForDark(Color color) {
  final hsl = HSLColor.fromColor(color);
  if (hsl.lightness >= 0.62) return color;
  // A deep red such as kahwa's maroon turns pink when it is only made
  // lighter, and salmon when its color is also taken out. Kept saturated and
  // turned a little towards orange, it stays the red of coffee.
  final deepRed = (hsl.hue >= 340 || hsl.hue <= 15) && hsl.lightness < 0.35;
  if (deepRed) {
    return HSLColor.fromAHSL(
      hsl.alpha,
      3,
      hsl.saturation.clamp(0.0, 0.62),
      0.6,
    ).toColor();
  }
  return hsl
      .withLightness(0.68)
      .withSaturation((hsl.saturation * 0.9).clamp(0.0, 1.0))
      .toColor();
}

/// The accent of a page in [brightness]: [color] itself on a light page, a
/// lighter tone of it on a dark one. For text and links.
Color accentFor(Color color, Brightness brightness) {
  return brightness == Brightness.dark ? liftForDark(color) : color;
}

/// The color of buttons, bars and other filled shapes in [brightness].
///
/// On a dark page a deep red such as kahwa's maroon stays the red brown of
/// the cup and of coffee, only bright enough to stand out from the page,
/// under white text. Other colors are the same as [accentFor].
Color fillFor(Color color, Brightness brightness) {
  if (brightness == Brightness.light) return color;
  final hsl = HSLColor.fromColor(color);
  final deepRed = (hsl.hue >= 340 || hsl.hue <= 15) && hsl.lightness < 0.35;
  if (!deepRed) return liftForDark(color);
  return HSLColor.fromAHSL(
    hsl.alpha,
    2,
    hsl.saturation.clamp(0.0, 0.5),
    0.44,
  ).toColor();
}
