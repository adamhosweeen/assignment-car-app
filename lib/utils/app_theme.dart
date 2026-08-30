import 'package:flutter/material.dart';
// The single sanctioned Cupertino usage (CLAUDE.md §5): the horizontal slide
// page transition. No CupertinoApp / Cupertino widgets anywhere else.
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:google_fonts/google_fonts.dart';

import 'package:assignment/utils/app_spacing.dart';

/// Colour tokens for the iOS-minimalist design system.
///
/// The ONLY place colours are defined (CLAUDE.md §5). Light mode only in v1,
/// but the names are kept semantic so a dark theme can be added later without
/// touching any widget.
abstract final class AppColors {
  /// Screen background.
  static const Color background = Color(0xFFFFFFFF);

  /// Behind grouped card sections.
  static const Color groupedBackground = Color(0xFFF2F2F7);

  /// Cards, sheets.
  static const Color surface = Color(0xFFFFFFFF);

  /// Buttons, links, active tab.
  static const Color primary = Color(0xFF007AFF);

  /// Hairline dividers.
  static const Color separator = Color(0xFFC6C6C8);

  /// Primary text.
  static const Color label = Color(0xFF000000);

  /// Supporting text — #3C3C43 at 60% opacity (alpha baked in to avoid the
  /// deprecated `withOpacity`).
  static const Color secondaryLabel = Color(0x993C3C43);

  /// Placeholders, disabled — #3C3C43 at 30% opacity.
  static const Color tertiaryLabel = Color(0x4C3C3C43);

  /// Delete, errors.
  static const Color destructive = Color(0xFFFF3B30);

  /// Sold badge, confirmations.
  static const Color success = Color(0xFF34C759);

  /// Text / icons drawn on top of [primary] or [destructive].
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// [primary] at 12% opacity — tinted fills behind primary-coloured content
  /// (e.g. the profile avatar), alpha baked in to avoid `withOpacity`.
  static const Color primaryMuted = Color(0x1F007AFF);

  /// iOS tertiary system fill — the track behind a segmented control.
  static const Color fill = Color(0x1F767680);
}

/// A single colour token, used to drive the design demo.
class AppColorToken {
  const AppColorToken(this.name, this.color, this.usage);

  final String name;
  final Color color;
  final String usage;
}

/// Every colour token in table order (mirrors CLAUDE.md §5).
const List<AppColorToken> kColorTokens = [
  AppColorToken('background', AppColors.background, 'Screen background'),
  AppColorToken(
    'groupedBackground',
    AppColors.groupedBackground,
    'Behind grouped card sections',
  ),
  AppColorToken('surface', AppColors.surface, 'Cards, sheets'),
  AppColorToken('primary', AppColors.primary, 'Buttons, links, active tab'),
  AppColorToken('separator', AppColors.separator, 'Hairline dividers'),
  AppColorToken('label', AppColors.label, 'Primary text'),
  AppColorToken('secondaryLabel', AppColors.secondaryLabel, 'Supporting text'),
  AppColorToken(
    'tertiaryLabel',
    AppColors.tertiaryLabel,
    'Placeholders, disabled',
  ),
  AppColorToken('destructive', AppColors.destructive, 'Delete, errors'),
  AppColorToken('success', AppColors.success, 'Sold badge, confirmations'),
];

/// Semantic iOS type styles mapped onto the Material [TextTheme] slots.
///
/// Widgets read named styles off the theme, e.g.
/// `Theme.of(context).textTheme.headline`, so no font size or weight literal
/// ever appears in a widget file.
extension AppTextStyles on TextTheme {
  /// 34 / bold.
  TextStyle get largeTitle => displaySmall!;

  /// 28 / bold.
  TextStyle get title1 => headlineMedium!;

  /// 20 / semibold.
  TextStyle get title3 => titleLarge!;

  /// 17 / semibold.
  TextStyle get headline => titleMedium!;

  /// 17 / regular.
  TextStyle get body => bodyLarge!;

  /// 15 / regular.
  TextStyle get subhead => bodyMedium!;

  /// 13 / regular.
  TextStyle get footnote => bodySmall!;

  /// 12 / regular.
  TextStyle get caption => labelSmall!;

  /// 10 / regular — bottom-nav labels (§5).
  TextStyle get navLabel => labelMedium!;
}

/// The app's single light theme.
abstract final class AppTheme {
  static ThemeData get light {
    final textTheme = _buildTextTheme();

    final colorScheme = const ColorScheme.light().copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.primary,
      onSecondary: AppColors.onPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.label,
      error: AppColors.destructive,
      onError: AppColors.onPrimary,
    );

    // No visible border on any input state (iOS filled fields, §5).
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
      borderSide: BorderSide.none,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      textTheme: textTheme,
      // Flat everywhere — no ripple, no shadows (§5).
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      dividerColor: AppColors.separator,
      // The one sanctioned Cupertino touch: the horizontal slide transition.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.separator,
        thickness: AppSpacing.hairline,
        space: AppSpacing.hairline,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.label,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.headline,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.groupedBackground,
        contentPadding: const EdgeInsets.all(AppSpacing.space12),
        hintStyle: textTheme.body.copyWith(color: AppColors.tertiaryLabel),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder,
        disabledBorder: inputBorder,
        errorBorder: inputBorder,
        focusedErrorBorder: inputBorder,
      ),
      // Primary CTA: full-width (at call site), 50px tall, radius 10, 17 semibold.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.groupedBackground,
          disabledForegroundColor: AppColors.tertiaryLabel,
          elevation: 0,
          minimumSize: const Size.fromHeight(AppSpacing.controlHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
          textStyle: textTheme.headline,
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      // Links.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: textTheme.body,
          splashFactory: NoSplash.splashFactory,
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    TextStyle style(
      double size,
      FontWeight weight, {
      double height = 1.3,
      double spacing = 0,
    }) {
      return GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: AppColors.label,
        height: height,
        letterSpacing: spacing,
      );
    }

    const regular = FontWeight.w400;
    const semibold = FontWeight.w600;
    const bold = FontWeight.w700;

    return TextTheme(
      // largeTitle 34 / bold
      displaySmall: style(34, bold, height: 1.15, spacing: -0.5),
      // title1 28 / bold
      headlineMedium: style(28, bold, height: 1.15, spacing: -0.4),
      // title3 20 / semibold
      titleLarge: style(20, semibold, height: 1.25, spacing: -0.2),
      // headline 17 / semibold
      titleMedium: style(17, semibold),
      // body 17 / regular
      bodyLarge: style(17, regular),
      // subhead 15 / regular
      bodyMedium: style(15, regular, height: 1.35),
      // footnote 13 / regular
      bodySmall: style(13, regular, height: 1.35),
      // caption 12 / regular
      labelSmall: style(12, regular, height: 1.35),
      // navLabel 10 / regular
      labelMedium: style(10, regular, height: 1.2),
    );
  }
}
