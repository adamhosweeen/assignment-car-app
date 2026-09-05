import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/common/select_sheet.dart';
import 'package:assignment/widgets/common/text_prompt.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/model/listing/car_catalog.dart';
import 'package:assignment/control/listings/sell_controller.dart';
import 'package:assignment/widgets/common/sell_step_scaffold.dart';

class StepIdentity extends StatefulWidget {
  const StepIdentity({super.key});

  @override
  State<StepIdentity> createState() => _StepIdentityState();
}

class _StepIdentityState extends State<StepIdentity> {
  late final TextEditingController _variant;

  @override
  void initState() {
    super.initState();
    _variant = TextEditingController(
      text: context.read<SellController>().draft.variant ?? '',
    );
  }

  @override
  void dispose() {
    _variant.dispose();
    super.dispose();
  }

  SellController get _notifier => context.read<SellController>();

  Future<void> _pickMake() async {
    final current = context.read<SellController>().draft.make;
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
    final draft = context.read<SellController>().draft;
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
      selected: context.read<SellController>().draft.year,
    );
    if (picked != null) _notifier.setYear(picked);
  }

  @override
  Widget build(BuildContext context) {
    final draft = context.watch<SellController>().draft;
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
