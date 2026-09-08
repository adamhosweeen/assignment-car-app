import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.hero,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.directions_car_filled,
                size: AppSpacing.iconXl,
                color: AppColors.onHero,
              ),
              const SizedBox(height: AppSpacing.space16),
              Text(
                'CarSell',
                style: Theme.of(
                  context,
                ).textTheme.largeTitle.copyWith(color: AppColors.onHero),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
