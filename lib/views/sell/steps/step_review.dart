import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assignment/utils/formatters.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/listing/media_image.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/control/listings/sell_controller.dart';
import 'package:assignment/widgets/common/sell_step_scaffold.dart';

class StepReview extends StatelessWidget {
  const StepReview({super.key, required this.onEditStep});

  final void Function(int step) onEditStep;

  @override
  Widget build(BuildContext context) {
    final d = context.watch<SellController>().draft;
    return SellStepScaffold(
      title: 'Review & publish',
      subtitle: 'Check everything, then publish. Tap Edit to change a section.',
      children: [
        if (d.photoPaths.isNotEmpty) ...[
          SizedBox(
            height: AppSpacing.thumbMd,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: d.photoPaths.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppSpacing.space8),
              itemBuilder: (_, i) => ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
                child: MediaImage(
                  path: d.photoPaths[i],
                  width: AppSpacing.thumbMd,
                  height: AppSpacing.thumbMd,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space24),
        ],
        _Section(
          title: 'Car',
          onEdit: () => onEditStep(1),
          rows: [
            ('Make', d.make ?? '—'),
            ('Model', d.model ?? '—'),
            ('Variant', d.variant ?? '—'),
            ('Year', d.year?.toString() ?? '—'),
          ],
        ),
        _Section(
          title: 'Specs',
          onEdit: () => onEditStep(2),
          rows: [
            (
              'Mileage',
              d.mileageKm != null ? formatMileage(d.mileageKm!) : '—',
            ),
            ('Transmission', d.transmission?.label ?? '—'),
            ('Fuel type', d.fuelType?.label ?? '—'),
            ('Body type', d.bodyType?.label ?? '—'),
            ('Colour', d.colour ?? '—'),
          ],
        ),
        _Section(
          title: 'Condition',
          onEdit: () => onEditStep(3),
          rows: [
            ('Previous owners', d.ownersCount?.toString() ?? '—'),
            ('Accident-free', (d.accidentFree ?? false) ? 'Yes' : 'No'),
            (
              'Road tax expiry',
              d.roadTaxExpiry != null ? formatDate(d.roadTaxExpiry!) : '—',
            ),
          ],
        ),
        _Section(
          title: 'Registration & location',
          onEdit: () => onEditStep(4),
          rows: [
            ('Region', d.registrationRegion?.label ?? '—'),
            ('State', d.state ?? '—'),
            ('City', d.city ?? '—'),
          ],
        ),
        _Section(
          title: 'Price',
          onEdit: () => onEditStep(5),
          rows: [
            (
              'Asking price',
              d.priceMyr != null ? formatPrice(d.priceMyr!) : '—',
            ),
            ('Negotiable', d.negotiable ? 'Yes' : 'No'),
            if (d.description != null) ('Description', d.description!),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.onEdit,
    required this.rows,
  });

  final String title;
  final VoidCallback onEdit;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.space4,
              bottom: AppSpacing.space8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: text.footnote.copyWith(
                    color: AppColors.secondaryLabel,
                  ),
                ),
                GestureDetector(
                  onTap: onEdit,
                  child: Text(
                    'Edit',
                    style: text.footnote.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          GroupedSection(
            children: [
              for (final (label, value) in rows)
                GroupedRow(label: label, value: value),
            ],
          ),
        ],
      ),
    );
  }
}
