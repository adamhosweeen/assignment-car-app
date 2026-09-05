import 'package:flutter/material.dart';

import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';

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

  final String? value;
  final String? hint;
  final VoidCallback? onTap;

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
