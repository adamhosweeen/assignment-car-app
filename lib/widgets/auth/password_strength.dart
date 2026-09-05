import 'package:flutter/material.dart';

import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/validators.dart';

class PasswordStrength extends StatelessWidget {
  const PasswordStrength({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final level = passwordStrength(password);
    final (color, label) = switch (level) {
      0 => (AppColors.fill, ''),
      1 => (AppColors.destructive, 'Weak'),
      2 => (AppColors.warning, 'Okay'),
      _ => (AppColors.success, 'Strong'),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 1; i <= 3; i++) ...[
              if (i > 1) const SizedBox(width: AppSpacing.space4),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: AppSpacing.strengthBarHeight,
                  decoration: BoxDecoration(
                    color: i <= level ? color : AppColors.fill,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusBar),
                  ),
                ),
              ),
            ],
            if (label.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.space12),
              Text(label, style: text.caption.copyWith(color: color)),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.space12),
        _Rule(met: hasMinLength(password), text: 'At least 8 characters'),
        _Rule(met: hasLetter(password), text: 'Contains a letter'),
        _Rule(met: hasDigit(password), text: 'Contains a number'),
      ],
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.met, required this.text});

  final bool met;
  final String text;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.footnote;
    final color = met ? AppColors.success : AppColors.tertiaryLabel;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            size: AppSpacing.iconSm,
            color: color,
          ),
          const SizedBox(width: AppSpacing.space8),
          Text(
            text,
            style: style.copyWith(
              color: met ? AppColors.label : AppColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}
