import 'package:flutter/material.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/dimens.dart';
import 'package:product_catalog/widgets/product_card.dart';
import 'package:product_catalog/widgets/shimmer_box.dart';

/// A loading skeleton with the same shape as a product card.
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(Dimens.cardPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Dimens.radiusLarge),
        border: Border.all(color: colors.border),
      ),
      child: const AppShimmer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(
              width: ProductCard.imageSize,
              height: ProductCard.imageSize,
              radius: Dimens.radiusMedium,
            ),
            SizedBox(width: Dimens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 64, height: 9),
                  SizedBox(height: Dimens.space8),
                  ShimmerBox(width: 170, height: 15),
                  SizedBox(height: Dimens.space8),
                  ShimmerBox(height: 10),
                  SizedBox(height: Dimens.space4),
                  ShimmerBox(width: 150, height: 10),
                  SizedBox(height: Dimens.space12),
                  ShimmerBox(width: 110, height: 16),
                  SizedBox(height: Dimens.space8),
                  ShimmerBox(width: 64, height: 9),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rows of [ProductCardShimmer]s, in one column or a grid.
///
/// Used for the first page and, with a smaller [count], at the bottom of the
/// list while the next page loads. It is not a ListView: the pagination
/// package puts the first-page indicator inside a SliverFillRemaining, which
/// measures its child's intrinsic height, and lazy viewports can't report one.
class ProductListShimmer extends StatelessWidget {
  const ProductListShimmer({this.count = 6, this.columns = 1, super.key});

  final int count;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final rows = (count / columns).ceil();
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          for (var row = 0; row < rows; row++) ...[
            if (row > 0) const SizedBox(height: Dimens.space12),
            Row(
              children: [
                for (var col = 0; col < columns; col++) ...[
                  if (col > 0) const SizedBox(width: Dimens.space12),
                  const Expanded(child: ProductCardShimmer()),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
