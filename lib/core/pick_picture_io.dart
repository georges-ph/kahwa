import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickPicture() async {
  final file = await ImagePicker().pickImage(source: ImageSource.gallery);
  return file?.readAsBytes();
}
