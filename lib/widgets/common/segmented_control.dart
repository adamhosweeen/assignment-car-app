import 'package:flutter/material.dart';

import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';

/// An iOS-style segmented control built from Material primitives: a tinted
/// track with the selected segment raised as a white pill (no shadow — the
/// contrast comes from colour alone, per §5).
class SegmentedControl extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  }) : assert(labels.length > 1);

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      height: AppSpacing.segmentHeight,
      padding: const EdgeInsets.all(AppSpacing.segmentInset),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSegment),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (i != selected) onChanged(i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: i == selected
                        ? AppColors.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusSegment - AppSpacing.segmentInset,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.footnote.copyWith(
                      fontWeight: i == selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: AppColors.label,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
