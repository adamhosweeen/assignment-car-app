import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:assignment/control/auth/registration_controller.dart';
import 'package:assignment/model/malaysian_states.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/common/select_sheet.dart';
import 'package:assignment/widgets/common/sell_step_scaffold.dart';

/// Registration step 3 — where the user is, via GPS or the state picker.
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
    final text = Theme.of(context).textTheme;

    return SellStepScaffold(
      title: 'Where are you?',
      subtitle: 'We use this to show you cars for sale near you.',
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
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.my_location,
                      size: AppSpacing.iconMd,
                      color: AppColors.primary,
                    ),
              onTap: s.detectingLocation
                  ? null
                  : ref
                        .read(registrationControllerProvider.notifier)
                        .detectLocation,
            ),
            GroupedRow(
              label: 'State',
              value: s.stateName ?? 'Select',
              valueColor: s.stateName == null ? AppColors.tertiaryLabel : null,
              showChevron: true,
              onTap: () => _pickState(context, ref),
            ),
          ],
        ),
        if (s.locationFailed) ...[
          const SizedBox(height: AppSpacing.space12),
          Text(
            "We couldn't detect your location — pick your state above.",
            style: text.footnote.copyWith(color: AppColors.secondaryLabel),
          ),
        ],
      ],
    );
  }
}
