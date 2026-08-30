import 'package:flutter/material.dart';

import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';

/// A fixed-width listing card for horizontal rows (the Buy feed's
/// "Recommended for you" strip). Same surface and cover-as-slot pattern as
/// [ListingCard], with price above a one-line title.
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
      child: Align(
        alignment: Alignment.topLeft,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            child: ColoredBox(
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  cover,
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space12,
                      vertical: AppSpacing.space8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatPrice(listing.priceMyr),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.headline,
                        ),
                        const SizedBox(height: AppSpacing.space4),
                        Text(
                          listing.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.footnote.copyWith(
                            color: AppColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
