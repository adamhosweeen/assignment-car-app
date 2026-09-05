import 'package:flutter/material.dart';

import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/model/listing/listing_media.dart';
import 'package:assignment/widgets/listing/media_image.dart';

class CoverImage extends StatelessWidget {
  const CoverImage({
    super.key,
    required this.media,
    this.height = AppSpacing.coverHeight,
  });

  final ListingMedia? media;
  final double height;

  @override
  Widget build(BuildContext context) {
    return MediaImage(
      path: media?.storagePath,
      width: double.infinity,
      height: height,
    );
  }
}
