import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:kahwa/core/qr_reader.dart';
import 'package:zxing2/qrcode.dart';

/// A PNG of the QR code of [text], drawn with [scale] pixels per square on a
/// white margin, like a picture shared by the WHISH app.
Uint8List qrPicture(String text, {int scale = 8}) {
  final matrix = Encoder.encode(text, ErrorCorrectionLevel.m).matrix!;
  const margin = 4;
  final size = (matrix.width + margin * 2) * scale;
  final image = img.Image(width: size, height: size)
    ..clear(img.ColorRgb8(255, 255, 255));
  for (var y = 0; y < matrix.height; y++) {
    for (var x = 0; x < matrix.width; x++) {
      // zxing2's encoder keeps its grid the other way round.
      if (matrix.get(y, x) != 1) continue;
      img.fillRect(
        image,
        x1: (x + margin) * scale,
        y1: (y + margin) * scale,
        x2: (x + margin + 1) * scale - 1,
        y2: (y + margin + 1) * scale - 1,
        color: img.ColorRgb8(0, 0, 0),
      );
    }
  }
  return img.encodePng(image);
}

void main() {
  test('reads the link in a QR picture', () {
    const link = 'https://whish.money/pay/abc123';
    expect(readQrCode(qrPicture(link)), link);
  });

  test('a big picture is read too', () {
    const link = 'https://whish.money/pay/xyz789';
    expect(readQrCode(qrPicture(link, scale: 40)), link);
  });

  test('a picture without a code gives nothing', () {
    final blank = img.Image(width: 200, height: 200)
      ..clear(img.ColorRgb8(255, 255, 255));
    expect(readQrCode(img.encodePng(blank)), isNull);
  });

  test('a file that is not a picture gives nothing', () {
    expect(readQrCode(Uint8List.fromList([1, 2, 3])), isNull);
  });
}
