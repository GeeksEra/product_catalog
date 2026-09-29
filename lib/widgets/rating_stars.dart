import 'package:flutter/material.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/app_text.dart';
import 'package:product_catalog/theme/dimens.dart';

/// Five stars filled to [rating], rounded to the nearest half star, with the
/// numeric value next to them unless [showValue] is false.
///
/// [RatingStars.compact] is a single star and the value, for dense rows.
class RatingStars extends StatelessWidget {
  const RatingStars({
    required this.rating,
    this.size = Dimens.iconSmall,
    this.showValue = true,
    super.key,
  }) : compact = false;

  const RatingStars.compact({
    required this.rating,
    this.size = Dimens.iconSmall,
    super.key,
  }) : compact = true,
       showValue = true;

  final double rating;
  final double size;
  final bool showValue;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final halves = (rating.clamp(0, 5) * 2).round();

    final Widget stars = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (compact)
          Icon(Icons.star_rounded, size: size, color: colors.rating)
        else
          for (var star = 1; star <= 5; star++)
            Icon(
              halves >= star * 2
                  ? Icons.star_rounded
                  : halves == star * 2 - 1
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
              size: size,
              color: colors.rating,
            ),
        if (showValue) ...[
          SizedBox(width: compact ? Dimens.space2 : Dimens.space4),
          Text(
            rating.toStringAsFixed(1),
            style: AppText.labelMedium(
              color: compact ? colors.text : colors.textSecondary,
            ).copyWith(fontWeight: compact ? AppText.semiBold : null),
          ),
        ],
      ],
    );

    return Semantics(
      label: 'Rated ${rating.toStringAsFixed(1)} out of 5',
      excludeSemantics: true,
      // The compact form is a small chip, like noon's rating badge.
      child: compact
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimens.space4 + Dimens.space2,
                vertical: Dimens.space2,
              ),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(Dimens.radiusSmall - 4),
                border: Border.all(color: colors.border),
              ),
              child: stars,
            )
          : stars,
    );
  }
}
