import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/widgets/grouped_section.dart';
import '../../../../../shared/widgets/select_sheet.dart';
import '../../../../../theme/app_spacing.dart';
import '../../../../../theme/app_theme.dart';
import '../../../domain/listing_enums.dart';
import '../../../domain/malaysian_states.dart';
import '../sell_controller.dart';
import '../sell_step_scaffold.dart';

/// Step 5 — registration region, state, city.
class StepLocation extends ConsumerStatefulWidget {
  const StepLocation({super.key});

  @override
  ConsumerState<StepLocation> createState() => _StepLocationState();
}

class _StepLocationState extends ConsumerState<StepLocation> {
  late final TextEditingController _city;

  @override
  void initState() {
    super.initState();
    _city = TextEditingController(
      text: ref.read(sellControllerProvider).city ?? '',
    );
  }

  @override
  void dispose() {
    _city.dispose();
    super.dispose();
  }

  SellController get _notifier => ref.read(sellControllerProvider.notifier);

  Future<void> _pickRegion() async {
    final picked = await showSelectSheet<RegistrationRegion>(
      context: context,
      title: 'Registration region',
      options: RegistrationRegion.values,
      labelOf: (r) => r.label,
      selected: ref.read(sellControllerProvider).registrationRegion,
    );
    if (picked != null) _notifier.setRegion(picked);
  }

  Future<void> _pickState() async {
    final picked = await showSelectSheet<String>(
      context: context,
      title: 'State',
      options: MalaysianStates.all,
      labelOf: (s) => s,
      selected: ref.read(sellControllerProvider).state,
    );
    if (picked != null) _notifier.setStateName(picked);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(sellControllerProvider);
    const placeholder = AppColors.tertiaryLabel;
    return SellStepScaffold(
      title: 'Registration & location',
      subtitle:
          'Where the car is registered can differ from where you are selling it.',
      children: [
        GroupedSection(
          children: [
            GroupedRow(
              label: 'Registration region',
              value: draft.registrationRegion?.label ?? 'Select',
              valueColor: draft.registrationRegion == null ? placeholder : null,
              showChevron: true,
              onTap: _pickRegion,
            ),
            GroupedRow(
              label: 'State',
              value: draft.state ?? 'Select',
              valueColor: draft.state == null ? placeholder : null,
              showChevron: true,
              onTap: _pickState,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space20),
        const FieldLabel('City'),
        TextField(
          controller: _city,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'e.g. Petaling Jaya'),
          onChanged: (v) =>
              _notifier.setCity(v.trim().isEmpty ? null : v.trim()),
        ),
      ],
    );
  }
}
