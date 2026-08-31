import 'package:flutter/material.dart';

import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';

/// The black header band used across the auth flow (welcome, login,
/// register): an optional back button and the caller's content pinned
/// bottom-left. Pair with [AuthSheet] for the white rounded form area
/// below it.
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

/// The white rounded sheet that sits under an [AuthHero]. A black layer is
/// painted behind it so the top corner notches show the hero colour, giving
/// the "sheet riding over the hero" look from the reference design.
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

/// Button styles for the monochrome auth screens. Local to the auth flow —
/// the rest of the app keeps the themed blue buttons.
abstract final class AuthButtons {
  /// Black filled CTA on the white sheet.
  static ButtonStyle dark(BuildContext context) => FilledButton.styleFrom(
    backgroundColor: AppColors.hero,
    foregroundColor: AppColors.onHero,
    disabledBackgroundColor: AppColors.groupedBackground,
    disabledForegroundColor: AppColors.tertiaryLabel,
  );

  /// White filled CTA on the black hero.
  static ButtonStyle light(BuildContext context) => FilledButton.styleFrom(
    backgroundColor: AppColors.onHero,
    foregroundColor: AppColors.hero,
  );

  /// White outlined secondary on the black hero.
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

  /// Black outlined secondary on the white sheet.
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
