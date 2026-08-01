import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/widgets/grouped_section.dart';
import '../../../../../shared/widgets/select_sheet.dart';
import '../../../../../shared/widgets/text_prompt.dart';
import '../../../../../theme/app_spacing.dart';
import '../../../../../theme/app_theme.dart';
import '../../../domain/car_catalog.dart';
import '../sell_controller.dart';
import '../sell_step_scaffold.dart';

/// Step 2 — make → model → variant (optional) → year.
class StepIdentity extends ConsumerStatefulWidget {
  const StepIdentity({super.key});

  @override
  ConsumerState<StepIdentity> createState() => _StepIdentityState();
}

class _StepIdentityState extends ConsumerState<StepIdentity> {
  late final TextEditingController _variant;

  @override
  void initState() {
    super.initState();
    _variant = TextEditingController(
      text: ref.read(sellControllerProvider).variant ?? '',
    );
  }

  @override
  void dispose() {
    _variant.dispose();
    super.dispose();
  }

  SellController get _notifier => ref.read(sellControllerProvider.notifier);

  Future<void> _pickMake() async {
    final current = ref.read(sellControllerProvider).make;
    final picked = await showSelectSheet<String>(
      context: context,
      title: 'Make',
      options: CarCatalog.makes,
      labelOf: (m) => m,
      selected: current,
    );
    if (picked == null) return;
    if (picked == CarCatalog.other) {
      if (!mounted) return;
      final custom = await promptForText(
        context,
        title: 'Make',
        hint: 'Enter make',
      );
      if (custom != null) _notifier.setMake(custom);
    } else {
      _notifier.setMake(picked);
    }
  }

  Future<void> _pickModel() async {
    final draft = ref.read(sellControllerProvider);
    if (draft.make == null) return;
    final picked = await showSelectSheet<String>(
      context: context,
      title: 'Model',
      options: CarCatalog.modelsFor(draft.make!),
      labelOf: (m) => m,
      selected: draft.model,
    );
    if (picked == null) return;
    if (picked == CarCatalog.other) {
      if (!mounted) return;
      final custom = await promptForText(
        context,
        title: 'Model',
        hint: 'Enter model',
      );
      if (custom != null) _notifier.setModel(custom);
    } else {
      _notifier.setModel(picked);
    }
  }

  Future<void> _pickYear() async {
    final years = [for (var y = DateTime.now().year; y >= 1970; y--) y];
    final picked = await showSelectSheet<int>(
      context: context,
      title: 'Year',
      options: years,
      labelOf: (y) => '$y',
      selected: ref.read(sellControllerProvider).year,
    );
    if (picked != null) _notifier.setYear(picked);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(sellControllerProvider);
    const placeholder = AppColors.tertiaryLabel;
    return SellStepScaffold(
      title: 'Car identity',
      children: [
        GroupedSection(
          children: [
            GroupedRow(
              label: 'Make',
              value: draft.make ?? 'Select',
              valueColor: draft.make == null ? placeholder : null,
              showChevron: true,
              onTap: _pickMake,
            ),
            GroupedRow(
              label: 'Model',
              value: draft.model ?? 'Select',
              valueColor: draft.model == null ? placeholder : null,
              showChevron: true,
              onTap: draft.make == null ? null : _pickModel,
            ),
            GroupedRow(
              label: 'Year',
              value: draft.year?.toString() ?? 'Select',
              valueColor: draft.year == null ? placeholder : null,
              showChevron: true,
              onTap: _pickYear,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space20),
        const FieldLabel('Variant (optional)'),
        TextField(
          controller: _variant,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(hintText: 'e.g. 1.5 AV'),
          onChanged: (v) =>
              _notifier.setVariant(v.trim().isEmpty ? null : v.trim()),
        ),
      ],
    );
  }
}
