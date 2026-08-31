import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:assignment/control/auth/registration_controller.dart';
import 'package:assignment/model/malaysian_states.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/common/inline_notice.dart';
import 'package:assignment/widgets/common/select_sheet.dart';
import 'package:assignment/widgets/common/sell_step_scaffold.dart';

/// Registration step 3 — where the user is, via GPS or the state picker.
/// Confirms the result inline so the user knows what was detected.
class StepPickLocation extends ConsumerWidget {
  const StepPickLocation({super.key});

  Future<void> _pickState(BuildContext context, WidgetRef ref) async {
    final picked = await showSelectSheet<String>(
      context: context,
      title: 'Your state',
      options: MalaysianStates.all,
      labelOf: (s) => s,
      selected: ref.read(registrationControllerProvider).stateName,
    );
    if (picked != null) {
      ref.read(registrationControllerProvider.notifier).setStateName(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(registrationControllerProvider);
    final notifier = ref.read(registrationControllerProvider.notifier);

    return SellStepScaffold(
      title: 'Where are you?',
      subtitle:
          'We show cars near you first and tell sellers roughly where '
          'buyers are — only your state, never your address.',
      children: [
        GroupedSection(
          children: [
            GroupedRow(
              label: 'Use my location',
              labelColor: AppColors.primary,
              value: '',
              trailing: s.detectingLocation
                  ? const SizedBox(
                      width: AppSpacing.iconMd,
                      height: AppSpacing.iconMd,
                      child: CircularProgressIndicator(
                        strokeWidth: AppSpacing.avatarRingWidth,
                      ),
                    )
                  : const Icon(
                      Icons.my_location,
                      size: AppSpacing.iconMd,
                      color: AppColors.primary,
                    ),
              onTap: s.detectingLocation ? null : notifier.detectLocation,
            ),
            GroupedRow(
              label: 'State',
              value: s.stateName ?? 'Choose manually',
              valueColor: s.stateName == null ? AppColors.tertiaryLabel : null,
              showChevron: true,
              onTap: () => _pickState(context, ref),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space12),
        if (s.stateName != null)
          InlineNotice(
            kind: NoticeKind.success,
            text:
                'Set to ${s.stateName}. You can change it any time in My '
                'Info.',
          )
        else if (s.locationFailed)
          const InlineNotice(
            kind: NoticeKind.error,
            text:
                'We couldn’t detect your location — choose your state '
                'from the list instead.',
          )
        else
          const InlineNotice(
            text:
                'Location is used for the “near you” recommendations and '
                'market insights for your state.',
          ),
      ],
    );
  }
}
