import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/control/providers.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';

/// Logo on white. Restores the session, then routes to Home or Login. Hard
/// capped well under the 2-second limit (V1_SPEC §4.1) — no network to wait on.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    final signedIn = ref.read(authRepositoryProvider).currentUser != null;
    context.go(signedIn ? '/home/buy' : '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    // Black like the Welcome screen it hands over to, so the signed-out
    // cold start reads as one continuous surface.
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
