import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_theme.dart';

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
    context.go(signedIn ? '/home/buy' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.directions_car_filled,
              size: AppSpacing.iconXl,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.space16),
            Text('Garaj', style: Theme.of(context).textTheme.largeTitle),
          ],
        ),
      ),
    );
  }
}
