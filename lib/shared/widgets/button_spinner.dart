import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';

/// A small white spinner sized to sit inside a primary [FilledButton] while a
/// request is in flight.
class ButtonSpinner extends StatelessWidget {
  const ButtonSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: AppSpacing.space20,
      width: AppSpacing.space20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: AppColors.onPrimary,
      ),
    );
  }
}
