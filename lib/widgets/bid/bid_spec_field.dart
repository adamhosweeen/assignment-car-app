import 'package:flutter/material.dart';

import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';

/// One labelled, boxed field in the bid form's car-spec grid — the layout in
/// the reference design: a small grey label with a bordered box under it, a
/// trailing chevron, and a muted fill when the value can't be changed.
///
/// On the bid form every spec field *is* locked: the car's brand, model,
/// year, variant, engine, transmission, mileage and region come from the
/// listing the bid is on, so a bidder can read them but never edit them.
/// [onTap] exists so the same field can be made interactive if a later screen
/// needs it; while it is null the box renders in its disabled styling and
/// swallows no taps.
class BidSpecField extends StatelessWidget {
  const BidSpecField({
    super.key,
    required this.label,
    required this.value,
    this.hint,
    this.onTap,
    this.info,
  });

  final String label;

  /// The chosen value, or null to show [hint] in placeholder styling.
  final String? value;
  final String? hint;
  final VoidCallback? onTap;

  /// Optional explanatory text behind an ⓘ next to the label (the reference
  /// design puts one on "Car Region").
  final String? info;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final enabled = onTap != null;
    final hasValue = value != null && value!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.footnote.copyWith(color: AppColors.secondaryLabel),
              ),
            ),
            if (info != null) ...[
              const SizedBox(width: AppSpacing.space4),
              Tooltip(
                message: info!,
                triggerMode: TooltipTriggerMode.tap,
                child: const Icon(
                  Icons.info_outline,
                  size: AppSpacing.iconSm,
                  color: AppColors.tertiaryLabel,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.space8),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            height: AppSpacing.controlHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
            decoration: BoxDecoration(
              // An editable field sits on white with a hairline border; a
              // locked one takes the grouped fill, the same "not yours to
              // change" cue the disabled button style uses.
              color: enabled ? AppColors.surface : AppColors.groupedBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
              border: Border.all(
                color: AppColors.separator,
                width: AppSpacing.hairline,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasValue ? value! : (hint ?? ''),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.body.copyWith(
                      color: hasValue
                          ? AppColors.label
                          : AppColors.tertiaryLabel,
                    ),
                  ),
                ),
                Icon(
                  enabled ? Icons.expand_more : Icons.lock_outline,
                  size: AppSpacing.iconSm,
                  color: AppColors.tertiaryLabel,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Lays [children] out two-per-row with even gutters, the way the reference
/// design pairs Brand/Model, Year/Variant and so on. An odd final field takes
/// the left column and leaves the right empty rather than stretching.
class BidSpecGrid extends StatelessWidget {
  const BidSpecGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: AppSpacing.space16));
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: children[i]),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: i + 1 < children.length
                  ? children[i + 1]
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
}
