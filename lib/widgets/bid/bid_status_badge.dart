import 'package:flutter/material.dart';

import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';

/// A small coloured pill showing where a bid stands. Mirrors [StatusBadge]
/// for listings, so the two read as the same component in the Bid tab.
class BidStatusBadge extends StatelessWidget {
  const BidStatusBadge({super.key, required this.status});

  final BidStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      BidStatus.pending => AppColors.primary,
      BidStatus.accepted => AppColors.success,
      BidStatus.rejected => AppColors.destructive,
      BidStatus.withdrawn => AppColors.secondaryLabel,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.space8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space8,
          vertical: AppSpacing.space4,
        ),
        child: Text(
          status.label,
          style: Theme.of(
            context,
          ).textTheme.caption.copyWith(color: AppColors.onPrimary),
        ),
      ),
    );
  }
}
