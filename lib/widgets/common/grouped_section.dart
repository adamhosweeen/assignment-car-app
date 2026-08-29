import 'package:flutter/material.dart';

import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';

/// An iOS-style grouped card: a rounded-12 white surface with inset hairline
/// dividers between rows. Sits on the grouped background (§5).
class GroupedSection extends StatelessWidget {
  const GroupedSection({super.key, required this.children, this.header});

  final List<Widget> children;
  final String? header;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i != children.length - 1) {
        rows.add(
          const Padding(
            padding: EdgeInsets.only(left: AppSpacing.space16),
            child: Divider(height: AppSpacing.hairline),
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.space4,
              bottom: AppSpacing.space8,
            ),
            child: Text(
              header!,
              style: Theme.of(
                context,
              ).textTheme.footnote.copyWith(color: AppColors.secondaryLabel),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: ColoredBox(
            color: AppColors.surface,
            child: Column(children: rows),
          ),
        ),
      ],
    );
  }
}

/// A single row inside a [GroupedSection]: a label with an optional right-hand
/// value, trailing widget (e.g. a switch), and chevron. Tappable when [onTap].
class GroupedRow extends StatelessWidget {
  const GroupedRow({
    super.key,
    required this.label,
    this.labelColor,
    this.value,
    this.valueColor,
    this.trailing,
    this.onTap,
    this.showChevron = false,
  });

  final String label;
  final Color? labelColor;
  final String? value;
  final Color? valueColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space12,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: labelColor == null
                ? text.body
                : text.body.copyWith(color: labelColor),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Text(
              value ?? '',
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: text.body.copyWith(
                color: valueColor ?? AppColors.secondaryLabel,
              ),
            ),
          ),
          ?trailing,
          if (showChevron)
            const Padding(
              padding: EdgeInsets.only(left: AppSpacing.space4),
              child: Icon(
                Icons.chevron_right,
                size: AppSpacing.iconMd,
                color: AppColors.tertiaryLabel,
              ),
            ),
        ],
      ),
    );
    if (onTap == null) return row;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: row,
    );
  }
}
