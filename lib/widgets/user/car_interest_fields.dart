import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:assignment/model/listing/car_catalog.dart';
import 'package:assignment/model/listing/listing_draft.dart' show kMaxPriceMyr;
import 'package:assignment/model/user/car_interests.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/common/multi_select_sheet.dart';
import 'package:assignment/widgets/common/select_sheet.dart';
import 'package:assignment/widgets/common/sell_step_scaffold.dart';

const String _noPreference = 'No preference';

const int _budgetMaxDigits = 9;

class CarInterestFields extends StatefulWidget {
  const CarInterestFields({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final CarInterests value;
  final ValueChanged<CarInterests> onChanged;

  static String? _amountError(int? amount) {
    if (amount == null) return null;
    if (amount <= 0) return 'Enter an amount more than RM 0.';
    if (amount > kMaxPriceMyr) {
      return 'That’s too high. Enter an amount under ${formatPrice(kMaxPriceMyr)}.';
    }
    return null;
  }

  static String? budgetMinError(CarInterests interests) =>
      _amountError(interests.budgetMinMyr);

  static String? budgetMaxError(CarInterests interests) {
    final own = _amountError(interests.budgetMaxMyr);
    if (own != null) return own;
    final min = interests.budgetMinMyr;
    final max = interests.budgetMaxMyr;
    if (min != null &&
        max != null &&
        budgetMinError(interests) == null &&
        max < min) {
      return 'The maximum can’t be lower than the minimum.';
    }
    return null;
  }

  static bool isBudgetValid(CarInterests interests) =>
      budgetMinError(interests) == null && budgetMaxError(interests) == null;

  @override
  State<CarInterestFields> createState() => _CarInterestFieldsState();
}

class _CarInterestFieldsState extends State<CarInterestFields> {
  late final TextEditingController _budgetMin;
  late final TextEditingController _budgetMax;

  @override
  void initState() {
    super.initState();
    _budgetMin = TextEditingController(
      text: widget.value.budgetMinMyr?.toString() ?? '',
    );
    _budgetMax = TextEditingController(
      text: widget.value.budgetMaxMyr?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _budgetMin.dispose();
    _budgetMax.dispose();
    super.dispose();
  }

  Future<void> _pickBrands() async {
    final picked = await showMultiSelectSheet<String>(
      context: context,
      title: 'Preferred brands',
      options: CarCatalog.makes,
      labelOf: (m) => m,
      selected: widget.value.makes,
    );
    if (picked != null) widget.onChanged(widget.value.copyWith(makes: picked));
  }

  Future<void> _pickBodyTypes() async {
    final picked = await showMultiSelectSheet<BodyType>(
      context: context,
      title: 'Body types',
      options: BodyType.values,
      labelOf: (b) => b.label,
      selected: widget.value.bodyTypes,
    );
    if (picked != null) {
      widget.onChanged(widget.value.copyWith(bodyTypes: picked));
    }
  }

  Future<void> _pickTransmission() async {
    final current = widget.value.transmission;
    final picked = await showSelectSheet<String>(
      context: context,
      title: 'Transmission',
      options: [_noPreference, ...Transmission.values.map((t) => t.label)],
      labelOf: (s) => s,
      selected: current?.label ?? _noPreference,
    );
    if (picked == null) return;
    widget.onChanged(
      widget.value.copyWith(
        transmission: Transmission.values
            .where((t) => t.label == picked)
            .firstOrNull,
      ),
    );
  }

  Future<void> _pickFuel() async {
    final current = widget.value.fuelType;
    final picked = await showSelectSheet<String>(
      context: context,
      title: 'Fuel type',
      options: [_noPreference, ...FuelType.values.map((f) => f.label)],
      labelOf: (s) => s,
      selected: current?.label ?? _noPreference,
    );
    if (picked == null) return;
    widget.onChanged(
      widget.value.copyWith(
        fuelType: FuelType.values.where((f) => f.label == picked).firstOrNull,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    const placeholder = AppColors.tertiaryLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GroupedSection(
          children: [
            GroupedRow(
              label: 'Brands',
              value: value.makes.isEmpty ? 'Any' : value.makes.join(', '),
              valueColor: value.makes.isEmpty ? placeholder : null,
              showChevron: true,
              onTap: _pickBrands,
            ),
            GroupedRow(
              label: 'Body types',
              value: value.bodyTypes.isEmpty
                  ? 'Any'
                  : value.bodyTypes.map((b) => b.label).join(', '),
              valueColor: value.bodyTypes.isEmpty ? placeholder : null,
              showChevron: true,
              onTap: _pickBodyTypes,
            ),
            GroupedRow(
              label: 'Transmission',
              value: value.transmission?.label ?? 'Any',
              valueColor: value.transmission == null ? placeholder : null,
              showChevron: true,
              onTap: _pickTransmission,
            ),
            GroupedRow(
              label: 'Fuel type',
              value: value.fuelType?.label ?? 'Any',
              valueColor: value.fuelType == null ? placeholder : null,
              showChevron: true,
              onTap: _pickFuel,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space20),
        const FieldLabel('Budget'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _BudgetField(
                controller: _budgetMin,
                hint: 'Min',
                error: CarInterestFields.budgetMinError(value),
                onChanged: (v) =>
                    widget.onChanged(widget.value.copyWith(budgetMinMyr: v)),
              ),
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: _BudgetField(
                controller: _budgetMax,
                hint: 'Max',
                error: CarInterestFields.budgetMaxError(value),
                onChanged: (v) =>
                    widget.onChanged(widget.value.copyWith(budgetMaxMyr: v)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BudgetField extends StatelessWidget {
  const _BudgetField({
    required this.controller,
    required this.hint,
    required this.error,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final String? error;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final message = error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(_budgetMaxDigits),
          ],
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.space12,
                right: AppSpacing.space8,
              ),
              child: Text('RM', style: text.body),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            hintText: hint,
          ),
          onChanged: (v) => onChanged(int.tryParse(v)),
        ),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.space8),
          Text(
            message,
            style: text.footnote.copyWith(color: AppColors.destructive),
          ),
        ],
      ],
    );
  }
}
