import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/control/services/signed_url_cache.dart';

class MediaImage extends StatelessWidget {
  const MediaImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
  });

  final String? path;
  final BoxFit fit;
  final double? width;
  final double? height;

  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final p = path;
    if (p == null || p.isEmpty) return _placeholder();
    if (p.startsWith('http')) return _network(p);

    final file = File(p);
    if (file.existsSync()) {
      return Image.file(file, width: width, height: height, fit: fit);
    }

    return FutureBuilder<String?>(
      future: context.read<SignedUrlCache>().resolve(p),
      builder: (_, snapshot) {
        final url = snapshot.data;
        return url == null ? _placeholder() : _network(url);
      },
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

  Widget _placeholder() =>
      placeholder ??
      Container(
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
