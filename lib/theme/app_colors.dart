import 'package:flutter/material.dart';

/// Design tokens for color. The palette follows noon.com: its yellow top bar,
/// navy and slate text, blue links, green ratings and coral deal tags.
///
/// Widgets read colors only through [AppColors.of] (or `context.colors`),
/// never from raw hex values or `Colors.*`. The light and dark palettes live
/// in `light_colors.dart` and `dark_colors.dart`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.surfaceHighlight,
    required this.text,
    required this.textSecondary,
    required this.textTertiary,
    required this.buttonPrimaryText,
    required this.border,
    required this.borderSecondary,
    required this.success,
    required this.error,
    required this.warning,
    required this.brand,
    required this.onBrand,
    required this.header,
    required this.onHeader,
    required this.searchField,
    required this.chipSelected,
    required this.onChipSelected,
    required this.sale,
    required this.rating,
  });

  /// brand/primary: CTAs, links and active states only.
  final Color primary;

  /// brand/secondary.
  final Color secondary;

  /// bg/primary: screen background.
  final Color background;

  /// bg/secondary: cards and inputs.
  final Color surface;

  /// bg/tertiary: chips, skeletons, image placeholders.
  final Color surfaceHighlight;

  /// text/heading/primary.
  final Color text;

  /// text/heading/secondary.
  final Color textSecondary;

  /// text/heading/tertiary.
  final Color textTertiary;

  /// Text and icons on top of a [primary] fill.
  final Color buttonPrimaryText;

  /// border/primary: the 1px card outline that replaces shadows.
  final Color border;

  /// border/secondary.
  final Color borderSecondary;

  /// status/success.
  final Color success;

  /// status/error.
  final Color error;

  /// status/warning.
  final Color warning;

  /// Brand yellow: the top bar in light mode, selected chips in dark mode.
  final Color brand;

  /// Text and icons on [brand].
  final Color onBrand;

  /// The large-title header and its search and chip rows.
  final Color header;

  /// Titles and icons on [header].
  final Color onHeader;

  /// The search field's fill inside the header.
  final Color searchField;

  /// A selected filter chip's fill.
  final Color chipSelected;

  /// A selected filter chip's label.
  final Color onChipSelected;

  /// Discount tags laid over product images.
  final Color sale;

  /// Rating stars.
  final Color rating;

  /// The palette of the nearest [Theme].
  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? surfaceHighlight,
    Color? text,
    Color? textSecondary,
    Color? textTertiary,
    Color? buttonPrimaryText,
    Color? border,
    Color? borderSecondary,
    Color? success,
    Color? error,
    Color? warning,
    Color? brand,
    Color? onBrand,
    Color? header,
    Color? onHeader,
    Color? searchField,
    Color? chipSelected,
    Color? onChipSelected,
    Color? sale,
    Color? rating,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHighlight: surfaceHighlight ?? this.surfaceHighlight,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      buttonPrimaryText: buttonPrimaryText ?? this.buttonPrimaryText,
      border: border ?? this.border,
      borderSecondary: borderSecondary ?? this.borderSecondary,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      brand: brand ?? this.brand,
      onBrand: onBrand ?? this.onBrand,
      header: header ?? this.header,
      onHeader: onHeader ?? this.onHeader,
      searchField: searchField ?? this.searchField,
      chipSelected: chipSelected ?? this.chipSelected,
      onChipSelected: onChipSelected ?? this.onChipSelected,
      sale: sale ?? this.sale,
      rating: rating ?? this.rating,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      primary: mix(primary, other.primary),
      secondary: mix(secondary, other.secondary),
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceHighlight: mix(surfaceHighlight, other.surfaceHighlight),
      text: mix(text, other.text),
      textSecondary: mix(textSecondary, other.textSecondary),
      textTertiary: mix(textTertiary, other.textTertiary),
      buttonPrimaryText: mix(buttonPrimaryText, other.buttonPrimaryText),
      border: mix(border, other.border),
      borderSecondary: mix(borderSecondary, other.borderSecondary),
      success: mix(success, other.success),
      error: mix(error, other.error),
      warning: mix(warning, other.warning),
      brand: mix(brand, other.brand),
      onBrand: mix(onBrand, other.onBrand),
      header: mix(header, other.header),
      onHeader: mix(onHeader, other.onHeader),
      searchField: mix(searchField, other.searchField),
      chipSelected: mix(chipSelected, other.chipSelected),
      onChipSelected: mix(onChipSelected, other.onChipSelected),
      sale: mix(sale, other.sale),
      rating: mix(rating, other.rating),
    );
  }
}

/// Shorthand for [AppColors.of].
extension AppColorsContext on BuildContext {
  AppColors get colors => AppColors.of(this);
}
