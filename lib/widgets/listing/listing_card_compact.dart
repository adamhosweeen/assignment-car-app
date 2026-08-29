import 'package:flutter/material.dart';

import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';

/// A fixed-width listing card for horizontal rows (the Buy feed's
/// "Recommended for you" strip). Same cover-as-slot pattern as [ListingCard].
class ListingCardCompact extends StatelessWidget {
  const ListingCardCompact({
    super.key,
    required this.listing,
    required this.cover,
    this.onTap,
  });

  final Listing listing;
  final Widget cover;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SizedBox(
      width: AppSpacing.recommendCardWidth,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              child: cover,
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              listing.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.subhead,
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(formatPrice(listing.priceMyr), style: text.headline),
          ],
        ),
      ),
    );
  }
}
