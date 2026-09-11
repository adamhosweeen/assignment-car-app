import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/user/auth/registration_controller.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/widgets/common/inline_notice.dart';
import 'package:assignment/widgets/common/sell_step_scaffold.dart';
import 'package:assignment/widgets/user/car_interest_fields.dart';

class StepInterests extends StatelessWidget {
  const StepInterests({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<RegistrationController>().state;
    final min = s.interests.budgetMinMyr;
    final max = s.interests.budgetMaxMyr;
    final badBudget = min != null && max != null && (min <= 0 || min > max);

    return SellStepScaffold(
      eyebrow: 'Optional',
      title: 'What are you looking for?',
      subtitle:
          'Tell us what you like and we’ll recommend matching cars and '
          'message you when one is listed. Skip it if you’re only selling.',
      children: [
        CarInterestFields(
          value: s.interests,
          onChanged: context.read<RegistrationController>().setInterests,
        ),
        const SizedBox(height: AppSpacing.space16),
        if (badBudget)
          const InlineNotice(
            kind: NoticeKind.error,
            text:
                'The minimum budget must be more than RM 0 and no higher '
                'than the maximum.',
          )
        else if (s.interests.isEmpty)
          const InlineNotice(
            text:
                'Nothing picked — that’s fine. You can set preferences later '
                'from Profile → Car Interests.',
          )
        else
          const InlineNotice(
            kind: NoticeKind.success,
            text: 'We’ll only recommend cars that match everything you picked.',
          ),
      ],
    );
  }
}
