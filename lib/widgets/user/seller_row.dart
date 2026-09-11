import 'package:flutter/material.dart';

import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/widgets/user/user_avatar.dart';

class SellerRow extends StatelessWidget {
  const SellerRow({super.key, required this.user, this.onTap});

  final AppUser user;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space12,
        ),
        child: Row(
          children: [
            UserAvatar(
              name: user.name,
              avatarUrl: user.avatarUrl,
              size: AppSpacing.avatarSm,
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.body,
                  ),
                  if (user.state != null)
                    Text(
                      user.state!,
                      style: text.footnote.copyWith(
                        color: AppColors.secondaryLabel,
                      ),
                    ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right,
                size: AppSpacing.iconMd,
                color: AppColors.tertiaryLabel,
              ),
          ],
        ),
      ),
    );
  }
}
