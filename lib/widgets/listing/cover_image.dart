import 'package:flutter/material.dart';

import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/model/listing/listing_media.dart';
import 'package:assignment/widgets/listing/media_image.dart';

/// A listing's full-width cover image. Source handling (local file / network
/// URL / Supabase bucket path → signed URL) is delegated to [MediaImage].
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
