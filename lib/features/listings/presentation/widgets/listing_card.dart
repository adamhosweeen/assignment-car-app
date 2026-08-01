import 'package:flutter/material.dart';

import '../../../../core/formatters.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/listing.dart';

/// The single listing card reused by the Buy feed and My Listings. The only
/// differences between the two screens are the optional [statusBadge] and
/// [trailing] actions (§4.4, §4.6).
class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    required this.cover,
    this.onTap,
    this.onLongPress,
    this.statusBadge,
    this.trailing,
  });

  final Listing listing;

  /// The cover image widget (kept as a slot so this file has no dart:io/image
  /// dependency and stays purely presentational).
  final Widget cover;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? statusBadge;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                child: cover,
              ),
              if (statusBadge != null)
                Positioned(
                  top: AppSpacing.space8,
                  left: AppSpacing.space8,
                  child: statusBadge!,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.space12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  listing.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.headline,
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(formatPrice(listing.priceMyr), style: text.title3),
          const SizedBox(height: AppSpacing.space4),
          Row(
            children: [
              Text(
                formatMileage(listing.mileageKm),
                style: text.footnote.copyWith(color: AppColors.secondaryLabel),
              ),
              Text(
                '   ·   ',
                style: text.footnote.copyWith(color: AppColors.tertiaryLabel),
              ),
              Text(
                formatDate(listing.createdAt),
                style: text.footnote.copyWith(color: AppColors.secondaryLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
