import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<Uint8List?> pickPicture() async {
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = 'image/*';
  final chosen = Completer<web.File?>();
  input.onchange = (web.Event _) {
    final files = input.files;
    if (!chosen.isCompleted) {
      chosen.complete(
        files == null || files.length == 0 ? null : files.item(0),
      );
    }
  }.toJS;
  input.oncancel = (web.Event _) {
    if (!chosen.isCompleted) chosen.complete(null);
  }.toJS;
  // Some browsers only open the chooser for an input that is in the page.
  input.style.display = 'none';
  web.document.body!.append(input);
  try {
    input.click();
    final file = await chosen.future;
    if (file == null) return null;
    final buffer = await file.arrayBuffer().toDart;
    return buffer.toDart.asUint8List();
  } finally {
    input.remove();
  }
}
