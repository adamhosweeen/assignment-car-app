import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:go_router/go_router.dart';

import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/widgets/auth/auth_hero.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.hero,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.directions_car_filled,
                        color: AppColors.onHero,
                        size: AppSpacing.iconXl,
                      ),
                      const SizedBox(height: AppSpacing.space12),
                      Text(
                        'Garaj',
                        style: text.largeTitle.copyWith(
                          color: AppColors.onHero,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'Buy and sell\nused cars',
                  style: text.largeTitle.copyWith(color: AppColors.onHero),
                ),
                const SizedBox(height: AppSpacing.space12),
                Text(
                  'Deal directly with sellers near you, '
                  'anywhere in Malaysia.',
                  style: text.subhead.copyWith(
                    color: AppColors.onHeroSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space32),
                FilledButton(
                  style: AuthButtons.light(context),
                  onPressed: () => context.push('/login'),
                  child: const Text('Log in'),
                ),
                const SizedBox(height: AppSpacing.space16),
                const _OrDivider(),
                const SizedBox(height: AppSpacing.space16),
                OutlinedButton(
                  style: AuthButtons.lightOutlined(context),
                  onPressed: () => context.push('/register'),
                  child: const Text('Sign up'),
                ),
                const SizedBox(height: AppSpacing.space8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            height: AppSpacing.hairline,
            color: AppColors.onHeroSecondary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
          child: Text(
            'or',
            style: Theme.of(
              context,
            ).textTheme.footnote.copyWith(color: AppColors.onHeroSecondary),
          ),
        ),
        const Expanded(
          child: Divider(
            height: AppSpacing.hairline,
            color: AppColors.onHeroSecondary,
          ),
        ),
      ],
    );
  }
}
