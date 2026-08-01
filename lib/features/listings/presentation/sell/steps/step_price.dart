import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/widgets/grouped_section.dart';
import '../../../../../theme/app_spacing.dart';
import '../../../../../theme/app_theme.dart';
import '../sell_controller.dart';
import '../sell_step_scaffold.dart';

/// Step 6 — asking price, negotiable toggle, and an optional description.
class StepPrice extends ConsumerStatefulWidget {
  const StepPrice({super.key});

  @override
  ConsumerState<StepPrice> createState() => _StepPriceState();
}

class _StepPriceState extends ConsumerState<StepPrice> {
  late final TextEditingController _price;
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(sellControllerProvider);
    _price = TextEditingController(text: draft.priceMyr?.toString() ?? '');
    _description = TextEditingController(text: draft.description ?? '');
  }

  @override
  void dispose() {
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  SellController get _notifier => ref.read(sellControllerProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(sellControllerProvider);
    return SellStepScaffold(
      title: 'Price',
      children: [
        const FieldLabel('Asking price (RM)'),
        TextField(
          controller: _price,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            prefixText: 'RM  ',
            hintText: '48000',
          ),
          onChanged: (v) => _notifier.setPrice(int.tryParse(v)),
        ),
        const SizedBox(height: AppSpacing.space20),
        GroupedSection(
          children: [
            GroupedRow(
              label: 'Negotiable',
              trailing: Switch(
                value: draft.negotiable,
                activeTrackColor: AppColors.primary,
                onChanged: _notifier.setNegotiable,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space20),
        const FieldLabel('Description (optional)'),
        TextField(
          controller: _description,
          maxLines: 5,
          maxLength: 1000,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Service history, condition, reason for selling…',
          ),
          onChanged: (v) =>
              _notifier.setDescription(v.trim().isEmpty ? null : v.trim()),
        ),
      ],
    );
  }
}
