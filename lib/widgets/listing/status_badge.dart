import 'package:flutter/material.dart';

import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/model/listing/listing_enums.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final ListingStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      ListingStatus.active => (AppColors.primary, 'Active'),
      ListingStatus.sold => (AppColors.success, 'Sold'),
      ListingStatus.draft => (AppColors.secondaryLabel, 'Draft'),
      ListingStatus.deleted => (AppColors.destructive, 'Deleted'),
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
          label,
          style: Theme.of(
            context,
          ).textTheme.caption.copyWith(color: AppColors.onPrimary),
        ),
      ),
    );
  }
}
