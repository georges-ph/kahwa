import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Patterns a creator can draw on their banner.
enum CoverPattern {
  plain,
  dots,
  waves,
  stripes,
  rings,
  grid;

  static CoverPattern of(int index) {
    return index >= 0 && index < values.length ? values[index] : plain;
  }
}

/// The colored banner at the top of a creator page.
class CoverBanner extends StatelessWidget {
  const CoverBanner({
    super.key,
    required this.color,
    this.pattern = CoverPattern.plain,
    this.height = 160,
    this.borderRadius,
    this.child,
  });

  final Color color;
  final CoverPattern pattern;
  final double height;
  final BorderRadius? borderRadius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(color);
    // A slight shift of hue and light across the banner gives it depth.
    final end = hsl
        .withHue((hsl.hue + 18) % 360)
        .withLightness((hsl.lightness * 0.8).clamp(0.0, 1.0))
        .toColor();
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [color, end],
            ),
          ),
          child: CustomPaint(painter: _PatternPainter(pattern), child: child),
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  _PatternPainter(this.pattern);

  final CoverPattern pattern;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    switch (pattern) {
      case CoverPattern.plain:
        return;
      case CoverPattern.dots:
        paint.style = PaintingStyle.fill;
        for (var y = 10.0; y < size.height; y += 22) {
          final shift = (y ~/ 22).isEven ? 0.0 : 11.0;
          for (var x = 10.0 + shift; x < size.width; x += 22) {
            canvas.drawCircle(Offset(x, y), 2.4, paint);
          }
        }
      case CoverPattern.waves:
        for (var y = -20.0; y < size.height + 20; y += 26) {
          final path = Path()..moveTo(0, y);
          for (var x = 0.0; x <= size.width; x += 8) {
            path.lineTo(x, y + math.sin(x / 28) * 7);
          }
          canvas.drawPath(path, paint);
        }
      case CoverPattern.stripes:
        paint.strokeWidth = 10;
        for (var x = -size.height; x < size.width; x += 34) {
          canvas.drawLine(
            Offset(x, size.height),
            Offset(x + size.height, 0),
            paint,
          );
        }
      case CoverPattern.rings:
        final center = Offset(size.width * 0.85, size.height * 0.2);
        for (var r = 30.0; r < size.width; r += 30) {
          canvas.drawCircle(center, r, paint);
        }
      case CoverPattern.grid:
        paint.strokeWidth = 1.2;
        for (var x = 0.0; x < size.width; x += 24) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        }
        for (var y = 0.0; y < size.height; y += 24) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
    }
  }

  @override
  bool shouldRepaint(_PatternPainter old) => old.pattern != pattern;
}
