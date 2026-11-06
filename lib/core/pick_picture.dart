import 'dart:typed_data';

import 'package:kahwa/core/pick_picture_io.dart'
    if (dart.library.js_interop) 'package:kahwa/core/pick_picture_web.dart'
    as impl;

/// Lets the user pick a picture, such as a screenshot of a QR code, and
/// returns its bytes. Null when they cancel.
///
/// The web uses the browser's own file chooser rather than image_picker,
/// whose web side failed in some browsers.
Future<Uint8List?> pickPicture() => impl.pickPicture();
