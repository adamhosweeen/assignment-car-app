import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    final signedIn = context.read<AuthRepository>().currentUser != null;
    context.go(signedIn ? '/home/buy' : '/welcome');
  }

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
                'Garaj',
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
