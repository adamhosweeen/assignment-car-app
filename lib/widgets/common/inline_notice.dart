import 'package:flutter/material.dart';

import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';

enum NoticeKind { error, info, success }

class InlineNotice extends StatelessWidget {
  const InlineNotice({
    super.key,
    required this.text,
    this.kind = NoticeKind.info,
  });

  final String text;
  final NoticeKind kind;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (kind) {
      NoticeKind.error => (
        AppColors.destructiveMuted,
        AppColors.destructive,
        Icons.error_outline,
      ),
      NoticeKind.success => (
        AppColors.successMuted,
        AppColors.success,
        Icons.check_circle_outline,
      ),
      NoticeKind.info => (
        AppColors.primaryMuted,
        AppColors.primary,
        Icons.info_outline,
      ),
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusNotice),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppSpacing.iconSm, color: fg),
          const SizedBox(width: AppSpacing.space8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.footnote.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}
