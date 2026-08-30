import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Compress an image on-device to a JPEG next to the source file and return
/// its path. Falls back to the original path if compression fails, so a
/// picker result is always usable.
///
/// Sell photos use the §3 defaults (longest edge 1920, q80); avatars pass a
/// smaller [maxDimension] since they only ever render at thumbnail size.
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

/// Longest edge for a profile photo — plenty for a 96pt avatar at 3×.
const int avatarMaxDimension = 512;

/// JPEG quality for a profile photo.
const int avatarQuality = 85;
