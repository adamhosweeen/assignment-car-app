import 'package:flutter/material.dart';

import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';

class BidStatusBadge extends StatelessWidget {
  const BidStatusBadge({super.key, required this.status});

  final BidStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      BidStatus.placed => AppColors.primary,
      BidStatus.won => AppColors.success,
      BidStatus.lost => AppColors.secondaryLabel,
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
