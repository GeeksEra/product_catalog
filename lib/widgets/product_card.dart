import 'package:flutter/material.dart';
import 'package:product_catalog/models/product.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/app_text.dart';
import 'package:product_catalog/theme/dimens.dart';
import 'package:product_catalog/widgets/app_network_image.dart';
import 'package:product_catalog/widgets/price_text.dart';
import 'package:product_catalog/widgets/rating_stars.dart';
import 'package:product_catalog/widgets/scale_tap.dart';
import 'package:product_catalog/widgets/stock_badge.dart';

/// Hero tag shared by the list thumbnail and the first detail gallery image.
String productHeroTag(int id) => 'product-image-$id';

/// A product row: image tile on the left, details on the right.
class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, required this.onTap, super.key});

  final Product product;
  final VoidCallback onTap;

  static const double imageSize = 104;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final brand = product.brand;
    final discount = product.discountPercentage;

    return ScaleTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(Dimens.cardPadding),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(Dimens.radiusLarge),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: productHeroTag(product.id),
                  child: Container(
                    width: imageSize,
                    height: imageSize,
                    padding: const EdgeInsets.all(Dimens.space8),
                    decoration: BoxDecoration(
                      color: colors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(Dimens.radiusMedium),
                    ),
                    child: AppNetworkImage(
                      url: product.thumbnail,
                      fit: BoxFit.contain,
                      cacheSize: imageSize,
                    ),
                  ),
                ),
                if (discount != null && discount >= 1)
                  Positioned(
                    left: Dimens.space4 + Dimens.space2,
                    top: Dimens.space4 + Dimens.space2,
                    child: DiscountTag(percent: discount),
                  ),
              ],
            ),
            const SizedBox(width: Dimens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (brand != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Dimens.space2),
                      child: Text(
                        brand.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.labelSmall(
                          color: colors.textTertiary,
                        ).copyWith(letterSpacing: 0.6),
                      ),
                    ),
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.headingSmall(color: colors.text),
                  ),
                  const SizedBox(height: Dimens.space2),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodySmall(color: colors.textSecondary),
                  ),
                  const SizedBox(height: Dimens.space8),
                  Wrap(
                    spacing: Dimens.space8,
                    runSpacing: Dimens.space2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      PriceText(price: product.price),
                      RatingStars.compact(rating: product.rating, size: 15),
                    ],
                  ),
                  const SizedBox(height: Dimens.space4),
                  StockBadge(inStock: product.inStock),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small "-10%" tag laid over a product image.
class DiscountTag extends StatelessWidget {
  const DiscountTag({required this.percent, super.key});

  final double percent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(Dimens.radiusPill),
      ),
      child: Text(
        '-${percent.round()}%',
        style: AppText.labelSmall(color: colors.buttonPrimaryText),
      ),
    );
  }
}
