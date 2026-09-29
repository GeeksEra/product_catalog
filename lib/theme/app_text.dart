import 'package:flutter/painting.dart';

/// Named text styles, following the BuddyBoss `AppText` scale.
///
/// Every style takes an optional [Color]. When it is left out, the color is
/// inherited from the theme's default text color.
abstract final class AppText {
  static const String fontFamily = 'Poppins';

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  /// The iOS-style large navigation title.
  static TextStyle largeTitle({Color? color}) => _style(32, bold, 1.2, color);

  /// The compact navigation bar title.
  static TextStyle navTitle({Color? color}) => _style(17, semiBold, 1.3, color);

  static TextStyle headingLarge({Color? color}) => _style(24, bold, 1.3, color);

  static TextStyle headingMedium({Color? color}) =>
      _style(20, semiBold, 1.3, color);

  static TextStyle headingSmall({Color? color}) =>
      _style(16, semiBold, 1.4, color);

  static TextStyle bodyLarge({Color? color}) => _style(16, regular, 1.5, color);

  static TextStyle bodyMedium({Color? color}) =>
      _style(14, regular, 1.5, color);

  static TextStyle bodySmall({Color? color}) => _style(12, regular, 1.5, color);

  static TextStyle buttonMedium({Color? color}) =>
      _style(14, semiBold, 1.2, color);

  static TextStyle labelLarge({Color? color}) => _style(14, medium, 1.4, color);

  static TextStyle labelMedium({Color? color}) =>
      _style(12, medium, 1.4, color);

  static TextStyle labelSmall({Color? color}) => _style(11, medium, 1.4, color);

  static TextStyle _style(
    double size,
    FontWeight weight,
    double height,
    Color? color,
  ) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
    );
  }
}
