import 'package:flutter/material.dart';

import 'package:assignment/model/notifications/app_notification.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';

class NotificationAvatar extends StatelessWidget {
  const NotificationAvatar({super.key, required this.kind});

  final NotificationKind kind;

  static IconData iconFor(NotificationKind kind) => switch (kind) {
    NotificationKind.welcome => Icons.waving_hand_outlined,
    NotificationKind.listingMatch => Icons.directions_car_outlined,
    NotificationKind.insightsUpdated => Icons.bar_chart,
    NotificationKind.bidPlaced => Icons.gavel_outlined,
    NotificationKind.bidAccepted => Icons.check_circle_outline,
    NotificationKind.bidRejected => Icons.cancel_outlined,
    NotificationKind.bidOutbid => Icons.trending_up,
    NotificationKind.auctionWon => Icons.emoji_events_outlined,
    NotificationKind.auctionEnded => Icons.timer_off_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.avatarSm,
      height: AppSpacing.avatarSm,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryMuted,
      ),
      child: Icon(
        iconFor(kind),
        size: AppSpacing.iconMd,
        color: AppColors.primary,
      ),
    );
  }
}
