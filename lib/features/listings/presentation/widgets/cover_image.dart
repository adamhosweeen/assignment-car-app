import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/listing_media.dart';

/// Renders a listing's cover. Shows the local file when it exists (the fake
/// backend stores on-device paths); otherwise a neutral placeholder. In the
/// Supabase build this becomes a signed-URL network image.
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
    final path = media?.storagePath;
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      return Image.file(
        File(path),
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
      );
    }
    return Container(
      width: double.infinity,
      height: height,
      color: AppColors.groupedBackground,
      child: const Center(
        child: Icon(
          Icons.directions_car_outlined,
          size: AppSpacing.iconXl,
          color: AppColors.tertiaryLabel,
        ),
      ),
    );
  }
}
