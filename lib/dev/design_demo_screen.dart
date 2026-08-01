import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Temporary design-system demo.
///
/// Renders every colour, text style, spacing value, radius, button, text field,
/// and a grouped spec section so the design system can be verified on a device.
/// This lives in `dev/` on purpose — it is throwaway scaffolding to be deleted
/// once real feature screens exist.
class DesignDemoScreen extends StatelessWidget {
  const DesignDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design System')),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.space16,
        ),
        children: const [
          _ColoursSection(),
          _SectionGap(),
          _TypographySection(),
          _SectionGap(),
          _SpacingSection(),
          _SectionGap(),
          _RadiusSection(),
          _SectionGap(),
          _ButtonsSection(),
          _SectionGap(),
          _TextFieldsSection(),
          _SectionGap(),
          _GroupedSpecSection(),
          _SectionGap(),
        ],
      ),
    );
  }
}

// ─── Shared bits ─────────────────────────────────────────────────────────────

class _SectionGap extends StatelessWidget {
  const _SectionGap();

  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: AppSpacing.space32);
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space16),
      child: Text(title, style: Theme.of(context).textTheme.title3),
    );
  }
}

/// #RRGGBB, or #AARRGGBB when the token carries alpha.
String _hex(Color color) {
  final argb = color.toARGB32();
  final opaque = (argb >> 24 & 0xFF) == 0xFF;
  if (opaque) {
    return '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
  return '#${argb.toRadixString(16).padLeft(8, '0').toUpperCase()}';
}

String _weightName(FontWeight? weight) {
  if (weight == FontWeight.w700) return 'bold';
  if (weight == FontWeight.w600) return 'semibold';
  return 'regular';
}

// ─── Colours ─────────────────────────────────────────────────────────────────

class _ColoursSection extends StatelessWidget {
  const _ColoursSection();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Colour'),
        for (final token in kColorTokens)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space12),
            child: Row(
              children: [
                Container(
                  width: AppSpacing.space32,
                  height: AppSpacing.space32,
                  decoration: BoxDecoration(
                    color: token.color,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
                    border: Border.all(
                      color: AppColors.separator,
                      width: AppSpacing.hairline,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(token.name, style: text.headline),
                      const SizedBox(height: AppSpacing.space4),
                      Text(
                        token.usage,
                        style: text.footnote.copyWith(
                          color: AppColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _hex(token.color),
                  style: text.caption.copyWith(color: AppColors.tertiaryLabel),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Typography ──────────────────────────────────────────────────────────────

class _TypographySection extends StatelessWidget {
  const _TypographySection();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final samples = <(String, TextStyle)>[
      ('largeTitle', text.largeTitle),
      ('title1', text.title1),
      ('title3', text.title3),
      ('headline', text.headline),
      ('body', text.body),
      ('subhead', text.subhead),
      ('footnote', text.footnote),
      ('caption', text.caption),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Typography — Inter'),
        for (final (name, style) in samples)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: style),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  '${style.fontSize?.toInt()} / ${_weightName(style.fontWeight)}',
                  style: text.caption.copyWith(color: AppColors.tertiaryLabel),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Spacing ─────────────────────────────────────────────────────────────────

class _SpacingSection extends StatelessWidget {
  const _SpacingSection();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Spacing scale'),
        for (final value in AppSpacing.scale)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'space${value.toInt()}  ·  ${value.toInt()}px',
                  style: text.footnote.copyWith(
                    color: AppColors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),
                Container(
                  width: value,
                  height: AppSpacing.space16,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.space4),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Radius ──────────────────────────────────────────────────────────────────

class _RadiusSection extends StatelessWidget {
  const _RadiusSection();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const samples = <(double, String)>[
      (AppSpacing.radiusInput, 'input / button'),
      (AppSpacing.radiusCard, 'card'),
      (AppSpacing.radiusSheet, 'sheet'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Corner radius'),
        Row(
          children: [
            for (final (radius, usage) in samples)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.space24),
                child: Column(
                  children: [
                    Container(
                      width: AppSpacing.space32,
                      height: AppSpacing.space32,
                      decoration: BoxDecoration(
                        color: AppColors.groupedBackground,
                        borderRadius: BorderRadius.circular(radius),
                        border: Border.all(
                          color: AppColors.separator,
                          width: AppSpacing.hairline,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    Text('${radius.toInt()}', style: text.headline),
                    Text(
                      usage,
                      style: text.caption.copyWith(
                        color: AppColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ─── Buttons ─────────────────────────────────────────────────────────────────

class _ButtonsSection extends StatelessWidget {
  const _ButtonsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Buttons'),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {},
            child: const Text('Primary button'),
          ),
        ),
        const SizedBox(height: AppSpacing.space12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: AppColors.onPrimary,
            ),
            onPressed: () {},
            child: const Text('Delete listing'),
          ),
        ),
        const SizedBox(height: AppSpacing.space12),
        const SizedBox(
          width: double.infinity,
          child: FilledButton(onPressed: null, child: Text('Disabled')),
        ),
        const SizedBox(height: AppSpacing.space8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {},
            child: const Text('Wrong number?'),
          ),
        ),
      ],
    );
  }
}

// ─── Text fields ─────────────────────────────────────────────────────────────

class _TextFieldsSection extends StatelessWidget {
  const _TextFieldsSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Text fields'),
        TextField(decoration: InputDecoration(hintText: 'Search listings')),
        SizedBox(height: AppSpacing.space12),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: '60000', prefixText: 'RM '),
        ),
        SizedBox(height: AppSpacing.space12),
        TextField(
          enabled: false,
          decoration: InputDecoration(hintText: 'Disabled field'),
        ),
      ],
    );
  }
}

// ─── Grouped spec section ────────────────────────────────────────────────────

class _GroupedSpecSection extends StatelessWidget {
  const _GroupedSpecSection();

  @override
  Widget build(BuildContext context) {
    const rows = <(String, String)>[
      ('Body type', 'SUV'),
      ('Colour', 'White'),
      ('Owners', '1'),
      ('Accident-free', 'Yes'),
      ('Road tax expiry', '12 Mar 2026'),
      ('Registration', 'Peninsular'),
    ];

    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      final (label, value) = rows[i];
      children.add(_SpecRow(label: label, value: value));
      if (i != rows.length - 1) {
        children.add(
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
        const _SectionHeader('Grouped spec section'),
        Container(
          width: double.infinity,
          color: AppColors.groupedBackground,
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            ),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space12,
      ),
      child: Row(
        children: [
          Text(label, style: text.body),
          const Spacer(),
          Text(
            value,
            style: text.body.copyWith(color: AppColors.secondaryLabel),
          ),
        ],
      ),
    );
  }
}
