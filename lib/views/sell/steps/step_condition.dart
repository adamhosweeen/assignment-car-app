import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assignment/utils/formatters.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/common/select_sheet.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/control/listings/sell_controller.dart';
import 'package:assignment/widgets/common/sell_step_scaffold.dart';

/// Step 4 — previous owners, accident-free, optional road-tax expiry.
class StepCondition extends StatelessWidget {
  const StepCondition({super.key});

  @override
  Widget build(BuildContext context) {
    final draft = context.watch<SellController>().draft;
    final notifier = context.read<SellController>();
    const placeholder = AppColors.tertiaryLabel;

    Future<void> pickOwners() async {
      final picked = await showSelectSheet<int>(
        context: context,
        title: 'Previous owners',
        options: [for (var i = 1; i <= 10; i++) i],
        labelOf: (o) => o == 10 ? '10+' : '$o',
        selected: draft.ownersCount,
      );
      if (picked != null) notifier.setOwners(picked);
    }

    Future<void> pickRoadTax() async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: draft.roadTaxExpiry ?? now,
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 2),
      );
      if (picked != null) notifier.setRoadTaxExpiry(picked);
    }

    return SellStepScaffold(
      title: 'Condition',
      children: [
        GroupedSection(
          children: [
            GroupedRow(
              label: 'Previous owners',
              value: draft.ownersCount?.toString() ?? 'Select',
              valueColor: draft.ownersCount == null ? placeholder : null,
              showChevron: true,
              onTap: pickOwners,
            ),
            GroupedRow(
              label: 'Accident-free',
              trailing: Switch(
                value: draft.accidentFree ?? false,
                activeTrackColor: AppColors.primary,
                onChanged: notifier.setAccidentFree,
              ),
            ),
            GroupedRow(
              label: 'Road tax expiry',
              value: draft.roadTaxExpiry != null
                  ? formatDate(draft.roadTaxExpiry!)
                  : 'Not set',
              valueColor: draft.roadTaxExpiry == null ? placeholder : null,
              showChevron: true,
              onTap: pickRoadTax,
            ),
          ],
        ),
        if (draft.roadTaxExpiry != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => notifier.setRoadTaxExpiry(null),
              child: const Text('Clear road tax date'),
            ),
          ),
      ],
    );
  }
}
