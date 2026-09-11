import 'package:flutter/material.dart';

import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';

class RankBarRow extends StatelessWidget {
  const RankBarRow({
    super.key,
    required this.rank,
    required this.label,
    required this.count,
    required this.fraction,
    this.sublabel,
  });

  final int rank;
  final String label;
  final String? sublabel;
  final int count;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppSpacing.rankWidth,
            child: Text(
              '$rank',
              style: text.subhead.copyWith(color: AppColors.tertiaryLabel),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: text.body,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space12),
                    Text(
                      formatCount(count),
                      style: text.subhead.copyWith(
                        color: AppColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
                if (sublabel != null)
                  Text(
                    sublabel!,
                    overflow: TextOverflow.ellipsis,
                    style: text.footnote.copyWith(
                      color: AppColors.secondaryLabel,
                    ),
                  ),
                const SizedBox(height: AppSpacing.space8),
                _Bar(fraction: fraction),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusBar),
      child: SizedBox(
        height: AppSpacing.rankBarHeight,
        child: Stack(
          children: [
            const ColoredBox(
              color: AppColors.primaryMuted,
              child: SizedBox.expand(),
            ),
            FractionallySizedBox(
              widthFactor: fraction.clamp(0, 1).toDouble(),
              child: const ColoredBox(
                color: AppColors.primary,
                child: SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
