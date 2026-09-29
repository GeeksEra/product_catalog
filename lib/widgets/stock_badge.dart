import 'package:flutter/material.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/app_text.dart';
import 'package:product_catalog/theme/dimens.dart';

/// "In Stock" or "Out of Stock", as a colored dot and label.
class StockBadge extends StatelessWidget {
  const StockBadge({required this.inStock, super.key});

  final bool inStock;

  @override
  Widget build(BuildContext context) {
    final color = inStock ? context.colors.success : context.colors.error;
    final label = inStock ? 'In Stock' : 'Out of Stock';

    return Semantics(
      label: 'Availability: $label',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: Dimens.space4 + Dimens.space2),
          Text(label, style: AppText.labelSmall(color: color)),
        ],
      ),
    );
  }
}
