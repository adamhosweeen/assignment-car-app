import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/widgets/grouped_section.dart';
import '../../../../../shared/widgets/select_sheet.dart';
import '../../../../../theme/app_spacing.dart';
import '../../../../../theme/app_theme.dart';
import '../../../domain/listing_enums.dart';
import '../sell_controller.dart';
import '../sell_step_scaffold.dart';

/// Step 3 — mileage, transmission, fuel type, body type, colour.
class StepSpecs extends ConsumerStatefulWidget {
  const StepSpecs({super.key});

  @override
  ConsumerState<StepSpecs> createState() => _StepSpecsState();
}

class _StepSpecsState extends ConsumerState<StepSpecs> {
  late final TextEditingController _mileage;
  late final TextEditingController _colour;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(sellControllerProvider);
    _mileage = TextEditingController(text: draft.mileageKm?.toString() ?? '');
    _colour = TextEditingController(text: draft.colour ?? '');
  }

  @override
  void dispose() {
    _mileage.dispose();
    _colour.dispose();
    super.dispose();
  }

  SellController get _notifier => ref.read(sellControllerProvider.notifier);

  Future<void> _pickTransmission() async {
    final picked = await showSelectSheet<Transmission>(
      context: context,
      title: 'Transmission',
      options: Transmission.values,
      labelOf: (t) => t.label,
      selected: ref.read(sellControllerProvider).transmission,
    );
    if (picked != null) _notifier.setTransmission(picked);
  }

  Future<void> _pickFuel() async {
    final picked = await showSelectSheet<FuelType>(
      context: context,
      title: 'Fuel type',
      options: FuelType.values,
      labelOf: (f) => f.label,
      selected: ref.read(sellControllerProvider).fuelType,
    );
    if (picked != null) _notifier.setFuel(picked);
  }

  Future<void> _pickBody() async {
    final picked = await showSelectSheet<BodyType>(
      context: context,
      title: 'Body type',
      options: BodyType.values,
      labelOf: (b) => b.label,
      selected: ref.read(sellControllerProvider).bodyType,
    );
    if (picked != null) _notifier.setBody(picked);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(sellControllerProvider);
    const placeholder = AppColors.tertiaryLabel;
    return SellStepScaffold(
      title: 'Specs',
      children: [
        const FieldLabel('Mileage (km)'),
        TextField(
          controller: _mileage,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(hintText: '60000'),
          onChanged: (v) => _notifier.setMileage(int.tryParse(v)),
        ),
        const SizedBox(height: AppSpacing.space20),
        GroupedSection(
          children: [
            GroupedRow(
              label: 'Transmission',
              value: draft.transmission?.label ?? 'Select',
              valueColor: draft.transmission == null ? placeholder : null,
              showChevron: true,
              onTap: _pickTransmission,
            ),
            GroupedRow(
              label: 'Fuel type',
              value: draft.fuelType?.label ?? 'Select',
              valueColor: draft.fuelType == null ? placeholder : null,
              showChevron: true,
              onTap: _pickFuel,
            ),
            GroupedRow(
              label: 'Body type',
              value: draft.bodyType?.label ?? 'Select',
              valueColor: draft.bodyType == null ? placeholder : null,
              showChevron: true,
              onTap: _pickBody,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space20),
        const FieldLabel('Colour'),
        TextField(
          controller: _colour,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'e.g. White'),
          onChanged: (v) =>
              _notifier.setColour(v.trim().isEmpty ? null : v.trim()),
        ),
      ],
    );
  }
}
