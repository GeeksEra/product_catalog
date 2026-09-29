import 'package:flutter/material.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/app_text.dart';
import 'package:product_catalog/theme/dark_colors.dart';
import 'package:product_catalog/theme/dimens.dart';
import 'package:product_catalog/theme/light_colors.dart';

/// Builds the light and dark [ThemeData] from the color tokens.
abstract final class AppTheme {
  static ThemeData light() => _build(lightColors, Brightness.light);

  static ThemeData dark() => _build(darkColors, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.buttonPrimaryText,
      secondary: c.secondary,
      onSecondary: c.text,
      error: c.error,
      onError: c.buttonPrimaryText,
      surface: c.background,
      onSurface: c.text,
      onSurfaceVariant: c.textSecondary,
      surfaceContainerHighest: c.surfaceHighlight,
      outline: c.border,
      outlineVariant: c.borderSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: AppText.fontFamily,
      scaffoldBackgroundColor: c.background,
      extensions: [c],
      textTheme: TextTheme(
        headlineLarge: AppText.headingLarge(color: c.text),
        headlineMedium: AppText.headingMedium(color: c.text),
        titleLarge: AppText.headingMedium(color: c.text),
        titleMedium: AppText.headingSmall(color: c.text),
        bodyLarge: AppText.bodyLarge(color: c.text),
        bodyMedium: AppText.bodyMedium(color: c.text),
        bodySmall: AppText.bodySmall(color: c.textSecondary),
        labelLarge: AppText.labelLarge(color: c.text),
        labelMedium: AppText.labelMedium(color: c.text),
        labelSmall: AppText.labelSmall(color: c.textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: AppText.headingMedium(color: c.text),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: Dimens.border),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.buttonPrimaryText,
          minimumSize: const Size(120, Dimens.minTapTarget),
          textStyle: AppText.buttonMedium(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.radiusSmall),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          minimumSize: const Size(Dimens.minTapTarget, Dimens.minTapTarget),
          textStyle: AppText.buttonMedium(),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
