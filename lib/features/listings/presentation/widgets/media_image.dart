import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_theme.dart';
import '../listings_providers.dart';

/// Displays a listing photo from any source:
/// - a local file path (a freshly-picked photo in the Sell flow) → [Image.file]
/// - an `http(s)` URL → cached network image
/// - a Supabase storage bucket path → resolved to a signed URL, then cached
/// Falls back to a neutral placeholder while loading or on failure.
class MediaImage extends ConsumerWidget {
  const MediaImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String? path;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = path;
    if (p == null || p.isEmpty) return _placeholder();
    if (p.startsWith('http')) return _network(p);

    final file = File(p);
    if (file.existsSync()) {
      return Image.file(file, width: width, height: height, fit: fit);
    }

    // A Supabase bucket path — resolve to a signed URL.
    return ref
        .watch(signedImageUrlProvider(p))
        .when(
          data: (url) => url == null ? _placeholder() : _network(url),
          loading: _placeholder,
          error: (_, _) => _placeholder(),
        );
  }

  Widget _network(String url) => CachedNetworkImage(
    imageUrl: url,
    width: width,
    height: height,
    fit: fit,
    placeholder: (_, _) => _placeholder(),
    errorWidget: (_, _, _) => _placeholder(),
  );

  Widget _placeholder() => Container(
    width: width,
    height: height,
    color: AppColors.groupedBackground,
    alignment: Alignment.center,
    child: const Icon(
      Icons.directions_car_outlined,
      size: AppSpacing.iconXl,
      color: AppColors.tertiaryLabel,
    ),
  );
}
