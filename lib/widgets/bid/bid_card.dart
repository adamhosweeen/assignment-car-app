import 'package:flutter/material.dart';

import 'package:assignment/model/bid/bid_with_listing.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/widgets/bid/bid_status_badge.dart';
import 'package:assignment/widgets/listing/cover_image.dart';

class BidCard extends StatelessWidget {
  const BidCard({
    super.key,
    required this.entry,
    required this.onOpenListing,
    this.subtitle,
    this.actions = const [],
  });

  final BidWithListing entry;
  final VoidCallback onOpenListing;

  final String? subtitle;

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final bid = entry.bid;
    final listing = entry.listing;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: ColoredBox(
        color: AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onOpenListing,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusInput,
                      ),
                      child: SizedBox(
                        width: AppSpacing.thumbMd,
                        height: AppSpacing.thumbMd,
                        child: CoverImage(
                          media: listing.cover,
                          height: AppSpacing.thumbMd,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  formatPrice(bid.amountMyr),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.headline,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.space8),
                              BidStatusBadge(status: bid.status),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          Text(
                            listing.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.subhead,
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          Text(
                            _askingLine(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.footnote.copyWith(
                              color: AppColors.secondaryLabel,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: AppSpacing.space4),
                            Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.footnote.copyWith(
                                color: AppColors.tertiaryLabel,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (actions.isNotEmpty) ...[
              const Divider(height: AppSpacing.hairline),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.space12),
                child: Row(
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.space12),
                      Expanded(child: actions[i]),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _askingLine() {
    final difference = entry.differenceMyr;
    final asking = '${formatPrice(entry.listing.priceMyr)} asking';
    if (difference == 0) return '$asking · at asking price';
    final magnitude = formatPrice(difference.abs());
    return '$asking · $magnitude ${difference < 0 ? 'below' : 'above'}';
  }
}
