import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<String> compressImage(
  String sourcePath, {
  int maxDimension = 1920,
  int quality = 80,
}) async {
  try {
    final out = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      '$sourcePath.c.jpg',
      minWidth: maxDimension,
      minHeight: maxDimension,
      quality: quality,
    );
    return out?.path ?? sourcePath;
  } catch (_) {
    return sourcePath;
  }
}

const int avatarMaxDimension = 512;

const int avatarQuality = 85;
