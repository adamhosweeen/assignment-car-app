import 'package:flutter/material.dart';

import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';

/// iOS grouped-list section label: small uppercase secondary text sitting
/// just above a card, inset to align with the card's content.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.space4,
        bottom: AppSpacing.space8,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(
          context,
        ).textTheme.footnote.copyWith(color: AppColors.secondaryLabel),
      ),
    );
  }
}
