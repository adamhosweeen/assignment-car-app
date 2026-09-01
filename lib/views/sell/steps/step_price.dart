import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:assignment/utils/formatters.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/model/listing/listing_draft.dart';
import 'package:assignment/control/listings/sell_controller.dart';
import 'package:assignment/widgets/common/sell_step_scaffold.dart';

/// Step 6 — asking price, negotiable toggle, and an optional description.
class StepPrice extends StatefulWidget {
  const StepPrice({super.key});

  @override
  State<StepPrice> createState() => _StepPriceState();
}

class _StepPriceState extends State<StepPrice> {
  late final TextEditingController _price;
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    final draft = context.read<SellController>().draft;
    _price = TextEditingController(text: draft.priceMyr?.toString() ?? '');
    _description = TextEditingController(text: draft.description ?? '');
  }

  @override
  void dispose() {
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  SellController get _notifier => context.read<SellController>();

  @override
  Widget build(BuildContext context) {
    final draft = context.watch<SellController>().draft;
    return SellStepScaffold(
      title: 'Price',
      children: [
        const FieldLabel('Asking price (RM)'),
        TextField(
          controller: _price,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            // `prefixText` is hidden until the field is focused or has text,
            // so "RM" would vanish on an empty, unfocused field. A prefixIcon
            // is always shown.
            prefixIcon: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.space12,
                right: AppSpacing.space8,
              ),
              child: Text('RM', style: Theme.of(context).textTheme.body),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            hintText: '48000',
          ),
          onChanged: (v) => _notifier.setPrice(int.tryParse(v)),
        ),
        if ((draft.priceMyr ?? 0) > kMaxPriceMyr) ...[
          const SizedBox(height: AppSpacing.space8),
          Text(
            'That price is too high. Enter an amount under ${formatPrice(kMaxPriceMyr)}.',
            style: Theme.of(
              context,
            ).textTheme.footnote.copyWith(color: AppColors.destructive),
          ),
        ],
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
