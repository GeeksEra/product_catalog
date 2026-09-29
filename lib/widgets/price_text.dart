import 'package:flutter/material.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/app_text.dart';

/// Formats `1899.99` as `$1,899.99`.
String formatPrice(double price) {
  final fixed = price.toStringAsFixed(2);
  final dot = fixed.indexOf('.');
  final whole = fixed.substring(0, dot);
  final grouped = whole.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '\$$grouped${fixed.substring(dot)}';
}

/// The price in the brand color.
class PriceText extends StatelessWidget {
  const PriceText({required this.price, this.large = false, super.key});

  final double price;

  /// Uses the bigger heading style, for the detail screen.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.primary;
    return Text(
      formatPrice(price),
      style: large
          ? AppText.headingLarge(color: color)
          : AppText.headingSmall(color: color),
    );
  }
}
