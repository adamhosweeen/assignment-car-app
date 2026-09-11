import 'package:flutter/material.dart';

import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/widgets/listing/media_image.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.size = AppSpacing.avatarLg,
    this.onTap,
  });

  ProfileAvatar.fromUser(
    AppUser user, {
    super.key,
    this.size = AppSpacing.avatarLg,
    this.onTap,
  }) : name = user.name,
       avatarUrl = user.avatarUrl;

  final String name;
  final String? avatarUrl;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final letterStyle = size >= AppSpacing.avatarLg
        ? Theme.of(context).textTheme.largeTitle
        : Theme.of(context).textTheme.headline;

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
        style: letterStyle.copyWith(color: AppColors.primary),
      ),
    );

    final url = avatarUrl;
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
