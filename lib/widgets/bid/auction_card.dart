import 'package:flutter/material.dart';

import 'package:assignment/model/bid/auction.dart';
import 'package:assignment/model/bid/auction_with_listing.dart';
import 'package:assignment/model/bid/bid_validation.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/widgets/listing/cover_image.dart';

class AuctionCard extends StatelessWidget {
  const AuctionCard({
    super.key,
    required this.entry,
    this.onTap,
    this.trailing,
    this.footer,
  });

  final AuctionWithListing entry;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final auction = entry.auction;
    final live = auction.isLive();
    final due = auction.status == AuctionStatus.running && auction.hasEnded();

    final String status;
    final Color statusColor;
    if (due) {
      status = 'Finalising…';
      statusColor = AppColors.warning;
    } else if (live) {
      status = formatCountdown(auction.remaining());
      statusColor = AppColors.warning;
    } else {
      status = auction.status.label;
      statusColor = AppColors.secondaryLabel;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: ColoredBox(
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                          media: entry.listing.cover,
                          height: AppSpacing.thumbMd,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: text.headline,
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          Text(
                            auction.highestBidMyr == null
                                ? 'Starts at ${formatPrice(auction.startingPriceMyr)}'
                                : formatPrice(auction.highestBidMyr!),
                            style: text.body.copyWith(color: AppColors.primary),
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          Text(
                            auction.bidCount == 0
                                ? 'No bids yet'
                                : '${auction.bidCount} '
                                      '${auction.bidCount == 1 ? 'bid' : 'bids'}',
                            style: text.footnote.copyWith(
                              color: AppColors.secondaryLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          status,
                          style: text.footnote.copyWith(color: statusColor),
                        ),
                        ?trailing,
                      ],
                    ),
                  ],
                ),
                ?footer,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
