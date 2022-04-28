import 'package:flutter/material.dart';
import 'package:kahwa/utils/colors.dart';

class ShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height * 0.4)
      ..quadraticBezierTo(
          size.width * 0.25,
          size.height * 0.4 + size.height * 0.05,
          size.width * 0.5,
          size.height * 0.4 + size.height * 0.05)
      ..quadraticBezierTo(size.width * 0.75,
          size.height * 0.4 + size.height * 0.05, size.width, size.height * 0.4)
      ..lineTo(size.width, size.height * 0.4)
      ..lineTo(size.width, 0)
      ..close();

    Paint paint = Paint()..color = kRedColor;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ShapePainter oldDelegate) => false;
}
