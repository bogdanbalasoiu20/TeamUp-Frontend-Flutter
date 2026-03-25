import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<File?> compressImage(File file) async {
  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    "${file.path}_compressed.jpg",
    quality: 70,
  );

  if (result == null) return null;

  return File(result.path);
}