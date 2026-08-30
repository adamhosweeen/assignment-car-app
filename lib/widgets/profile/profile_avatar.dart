import 'package:flutter/material.dart';

import 'package:assignment/model/profile/profile.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/widgets/listing/media_image.dart';

/// A circular profile picture: the uploaded photo when `avatarUrl` is set
/// (initials show underneath while it loads), otherwise the first letter of
/// the display name on a tinted disc. With [onTap], a small camera badge
/// signals that the photo can be changed.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.profile,
    this.size = AppSpacing.avatarLg,
    this.onTap,
  });

  final Profile profile;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final source = profile.displayName;
    final initial = source.isNotEmpty ? source[0].toUpperCase() : '?';

    final initials = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryMuted,
        border: Border.all(
          color: AppColors.primary,
          width: AppSpacing.avatarRingWidth,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: Theme.of(
          context,
        ).textTheme.largeTitle.copyWith(color: AppColors.primary),
      ),
    );

    final url = profile.avatarUrl;
    final disc = url == null
        ? initials
        : ClipOval(
            child: MediaImage(
              path: url,
              width: size,
              height: size,
              placeholder: initials,
            ),
          );

    if (onTap == null) return disc;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            disc,
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: AppSpacing.avatarBadge,
                height: AppSpacing.avatarBadge,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(
                    color: AppColors.background,
                    width: AppSpacing.avatarRingWidth,
                  ),
                ),
                child: const Icon(
                  Icons.photo_camera,
                  size: AppSpacing.iconSm,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
