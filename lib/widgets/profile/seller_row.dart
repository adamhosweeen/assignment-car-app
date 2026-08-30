import 'package:flutter/material.dart';

import 'package:assignment/model/profile/public_profile.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/widgets/profile/profile_avatar.dart';

/// A tappable row for another user: small avatar, name, state, chevron.
/// Lives inside a [GroupedSection] (seller search results, Listing Detail).
class SellerRow extends StatelessWidget {
  const SellerRow({super.key, required this.profile, this.onTap});

  final PublicProfile profile;
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
            ProfileAvatar(
              name: profile.name,
              avatarUrl: profile.avatarUrl,
              size: AppSpacing.avatarSm,
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.body,
                  ),
                  if (profile.state != null)
                    Text(
                      profile.state!,
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
