import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:assignment/control/auth/registration_controller.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/widgets/profile/car_interest_fields.dart';
import 'package:assignment/widgets/common/sell_step_scaffold.dart';

/// Registration step 4 — the car-interest questionnaire. All optional; the
/// answers power the "Recommended for you" row on the Buy feed.
class StepInterests extends ConsumerWidget {
  const StepInterests({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(registrationControllerProvider);
    final text = Theme.of(context).textTheme;
    final min = s.interests.budgetMinMyr;
    final max = s.interests.budgetMaxMyr;
    final badBudget = min != null && max != null && (min <= 0 || min > max);

    return SellStepScaffold(
      title: 'What are you looking for?',
      subtitle:
          'Optional — we use this to recommend cars for you. '
          'You can change it any time from your profile.',
      children: [
        CarInterestFields(
          value: s.interests,
          onChanged: ref
              .read(registrationControllerProvider.notifier)
              .setInterests,
        ),
        if (badBudget) ...[
          const SizedBox(height: AppSpacing.space8),
          Text(
            'The minimum budget must be more than RM 0 and no higher than '
            'the maximum.',
            style: text.footnote.copyWith(color: AppColors.destructive),
          ),
        ],
      ],
    );
  }
}
