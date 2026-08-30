import 'package:flutter/material.dart';

import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/model/listing/listing.dart';

/// The single listing card reused by the Buy feed and My Listings. The only
/// differences between the two screens are the optional [statusBadge] and
/// [trailing] actions (§4.4, §4.6).
///
/// A white rounded surface meant to sit on [AppColors.groupedBackground]:
/// cover photo flush on top, then price (the hero), title, and a meta line of
/// mileage · location with the posted date at the right.
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: ColoredBox(
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  cover,
                  if (statusBadge != null)
                    Positioned(
                      top: AppSpacing.space8,
                      left: AppSpacing.space8,
                      child: statusBadge!,
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.space12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            formatPrice(listing.priceMyr),
                            style: text.title3,
                          ),
                        ),
                        ?trailing,
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      listing.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.body,
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${formatMileage(listing.mileageKm)} · '
                            '${listing.state}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.footnote.copyWith(
                              color: AppColors.secondaryLabel,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space8),
                        Text(
                          formatDate(listing.createdAt),
                          style: text.footnote.copyWith(
                            color: AppColors.tertiaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
