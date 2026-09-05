import 'package:flutter/material.dart';

import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';

class AuthHero extends StatelessWidget {
  const AuthHero({
    super.key,
    required this.child,
    this.onBack,
    this.backIcon = Icons.arrow_back_ios_new,
    this.height = AppSpacing.heroHeight,
  });

  final Widget child;
  final VoidCallback? onBack;
  final IconData backIcon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Container(
      height: height + topInset,
      color: AppColors.hero,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        topInset,
        AppSpacing.screenPadding,
        AppSpacing.space24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onBack != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.space8),
              child: IconButton(
                onPressed: onBack,
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                constraints: const BoxConstraints(
                  minWidth: AppSpacing.minTouchTarget,
                  minHeight: AppSpacing.minTouchTarget,
                ),
                icon: Icon(
                  backIcon,
                  color: AppColors.onHero,
                  size: AppSpacing.iconMd,
                ),
              ),
            ),
          const Spacer(),
          child,
        ],
      ),
    );
  }
}

class AuthSheet extends StatelessWidget {
  const AuthSheet({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.screenPadding,
      AppSpacing.space32,
      AppSpacing.screenPadding,
      AppSpacing.space16,
    ),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.hero,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusHero),
          ),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

abstract final class AuthButtons {
  static ButtonStyle dark(BuildContext context) => FilledButton.styleFrom(
    backgroundColor: AppColors.hero,
    foregroundColor: AppColors.onHero,
    disabledBackgroundColor: AppColors.groupedBackground,
    disabledForegroundColor: AppColors.tertiaryLabel,
  );

  static ButtonStyle light(BuildContext context) => FilledButton.styleFrom(
    backgroundColor: AppColors.onHero,
    foregroundColor: AppColors.hero,
  );

  static ButtonStyle lightOutlined(BuildContext context) =>
      OutlinedButton.styleFrom(
        foregroundColor: AppColors.onHero,
        side: const BorderSide(color: AppColors.onHero),
        minimumSize: const Size.fromHeight(AppSpacing.controlHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
        ),
        textStyle: Theme.of(context).textTheme.headline,
        splashFactory: NoSplash.splashFactory,
      );

  static ButtonStyle darkOutlined(BuildContext context) =>
      OutlinedButton.styleFrom(
        foregroundColor: AppColors.hero,
        side: const BorderSide(color: AppColors.hero),
        minimumSize: const Size.fromHeight(AppSpacing.controlHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
        ),
        textStyle: Theme.of(context).textTheme.headline,
        splashFactory: NoSplash.splashFactory,
      );
}
