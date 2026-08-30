import 'package:flutter/material.dart';

import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';

/// Shared layout for a single sell step: a scrollable, padded column with a
/// title and optional subtitle above the step's fields.
class SellStepScaffold extends StatelessWidget {
  const SellStepScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.space16,
        AppSpacing.screenPadding,
        AppSpacing.space32,
      ),
      children: [
        Text(title, style: text.title1),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.space8),
          Text(
            subtitle!,
            style: text.subhead.copyWith(color: AppColors.secondaryLabel),
          ),
        ],
        const SizedBox(height: AppSpacing.space24),
        ...children,
      ],
    );
  }
}

/// A small left-aligned field label above a text input.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.space4,
        bottom: AppSpacing.space8,
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.footnote.copyWith(color: AppColors.secondaryLabel),
      ),
    );
  }
}
