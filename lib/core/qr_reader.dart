import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

/// The text inside the QR code in the picture [bytes] (PNG, JPEG, WebP...),
/// or null when the picture has none that can be read.
///
/// Pure Dart, so it works the same in the apps and on the web. Used to read
/// a creator's WHISH link from the "Whish Me" code the WHISH app shares as a
/// picture.
String? readQrCode(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image == null) return null;
  final candidates = [
    image,
    // Big screenshots read better, and much faster, a little smaller.
    if (image.width > 1400) img.copyResize(image, width: 1000),
  ];
  for (final candidate in candidates) {
    final source = RGBLuminanceSource(
      candidate.width,
      candidate.height,
      _argb(candidate),
    );
    for (final binarizer in [
      HybridBinarizer.new,
      GlobalHistogramBinarizer.new,
    ]) {
      try {
        return QRCodeReader()
            .decode(BinaryBitmap(binarizer(source)), hints: _hints)
            .text;
      } catch (_) {
        // Not found, or not readable with this binarizer: try the next.
      }
    }
  }
  return null;
}

/// The pixels of [image] as the 0xAARRGGBB numbers zxing reads, on white
/// where the picture is see-through.
Int32List _argb(img.Image image) {
  final out = Int32List(image.width * image.height);
  var i = 0;
  for (final p in image) {
    final a = p.aNormalized;
    int blend(num c) => (c * a + 255 * (1 - a)).round();
    out[i++] =
        0xFF000000 |
        blend(p.rNormalized * 255) << 16 |
        blend(p.gNormalized * 255) << 8 |
        blend(p.bNormalized * 255);
  }
  return out;
}

/// Look harder than the default for a code anywhere in the picture.
final _hints = DecodeHints()..put(DecodeHintType.tryHarder);
