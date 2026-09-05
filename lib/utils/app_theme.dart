import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:google_fonts/google_fonts.dart';

import 'package:assignment/utils/app_spacing.dart';

abstract final class AppColors {
  static const Color background = Color(0xFFFFFFFF);

  static const Color groupedBackground = Color(0xFFF2F2F7);

  static const Color surface = Color(0xFFFFFFFF);

  static const Color primary = Color(0xFF007AFF);

  static const Color separator = Color(0xFFC6C6C8);

  static const Color label = Color(0xFF000000);

  static const Color secondaryLabel = Color(0x993C3C43);

  static const Color tertiaryLabel = Color(0x4C3C3C43);

  static const Color destructive = Color(0xFFFF3B30);

  static const Color success = Color(0xFF34C759);

  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color primaryMuted = Color(0x1F007AFF);

  static const Color fill = Color(0x1F767680);

  static const Color destructiveMuted = Color(0x1FFF3B30);

  static const Color successMuted = Color(0x1F34C759);

  static const Color warning = Color(0xFFFF9500);

  static const Color hero = Color(0xFF000000);

  static const Color onHero = Color(0xFFFFFFFF);

  static const Color onHeroSecondary = Color(0x99FFFFFF);

  static const Color heroBlob = Color(0x14FFFFFF);
}

class AppColorToken {
  const AppColorToken(this.name, this.color, this.usage);

  final String name;
  final Color color;
  final String usage;
}

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
  AppColorToken('warning', AppColors.warning, 'Password strength "okay"'),
  AppColorToken('primaryMuted', AppColors.primaryMuted, 'Tinted fills, info'),
  AppColorToken(
    'destructiveMuted',
    AppColors.destructiveMuted,
    'Inline error notice fill',
  ),
  AppColorToken(
    'successMuted',
    AppColors.successMuted,
    'Inline success notice fill',
  ),
  AppColorToken('fill', AppColors.fill, 'Segmented-control track'),
  AppColorToken('hero', AppColors.hero, 'Auth hero background'),
  AppColorToken('onHero', AppColors.onHero, 'Text on the auth hero'),
  AppColorToken(
    'onHeroSecondary',
    AppColors.onHeroSecondary,
    'Supporting text on the auth hero',
  ),
  AppColorToken('heroBlob', AppColors.heroBlob, 'Auth hero blob shapes'),
];

extension AppTextStyles on TextTheme {
  TextStyle get largeTitle => displaySmall!;

  TextStyle get title1 => headlineMedium!;

  TextStyle get title3 => titleLarge!;

  TextStyle get headline => titleMedium!;

  TextStyle get body => bodyLarge!;

  TextStyle get subhead => bodyMedium!;

  TextStyle get footnote => bodySmall!;

  TextStyle get caption => labelSmall!;

  TextStyle get navLabel => labelMedium!;
}

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
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      dividerColor: AppColors.separator,
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
      displaySmall: style(34, bold, height: 1.15, spacing: -0.5),
      headlineMedium: style(28, bold, height: 1.15, spacing: -0.4),
      titleLarge: style(20, semibold, height: 1.25, spacing: -0.2),
      titleMedium: style(17, semibold),
      bodyLarge: style(17, regular),
      bodyMedium: style(15, regular, height: 1.35),
      bodySmall: style(13, regular, height: 1.35),
      labelSmall: style(12, regular, height: 1.35),
      labelMedium: style(10, regular, height: 1.2),
    );
  }
}
