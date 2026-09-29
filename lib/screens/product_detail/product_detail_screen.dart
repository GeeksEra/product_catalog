import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:product_catalog/config/service_locator.dart';
import 'package:product_catalog/models/product.dart';
import 'package:product_catalog/models/review.dart';
import 'package:product_catalog/screens/image_viewer/image_viewer_screen.dart';
import 'package:product_catalog/screens/qr_viewer/qr_viewer_screen.dart';
import 'package:product_catalog/stores/product_detail_store.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/app_text.dart';
import 'package:product_catalog/theme/dimens.dart';
import 'package:product_catalog/widgets/error_view.dart';
import 'package:product_catalog/widgets/frosted_surface.dart';
import 'package:product_catalog/widgets/image_gallery.dart';
import 'package:product_catalog/widgets/price_text.dart';
import 'package:product_catalog/widgets/product_card.dart';
import 'package:product_catalog/widgets/qr_code_card.dart';
import 'package:product_catalog/widgets/rating_stars.dart';
import 'package:product_catalog/widgets/review_tile.dart';
import 'package:product_catalog/widgets/shimmer_box.dart';

/// Full details for one product.
///
/// A full-bleed gallery collapses into a compact bar as the page scrolls. The
/// header (gallery, title, price) renders straight away from the list
/// [product]; reviews and the QR code appear once the full product loads.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({required this.product, super.key});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final ProductDetailStore _store = getIt<ProductDetailStore>(
    param1: widget.product,
  )..load();
  final ScrollController _scroll = ScrollController();

  /// Whether the gallery has scrolled away and the bar shows the title.
  final ValueNotifier<bool> _collapsed = ValueNotifier(false);
  double _galleryHeight = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_updateCollapsed);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _collapsed.dispose();
    super.dispose();
  }

  void _updateCollapsed() {
    final topInset = MediaQuery.paddingOf(context).top;
    final threshold = _galleryHeight - kToolbarHeight - topInset - 24;
    _collapsed.value = _scroll.offset > threshold;
  }

  void _openImage(List<String> images, int index) {
    // The root navigator, so the viewer also covers the tab bar.
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (_, _, _) =>
            ImageViewerScreen(images: images, initialIndex: index),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _openQr(Product product, QrSource source) {
    // The root navigator, so the viewer also covers the tab bar.
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, _, _) => QrViewerScreen(
          source: source,
          data: _qrData(product),
          url: product.meta?.qrCode,
          productTitle: product.title,
        ),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  static String _qrData(Product product) =>
      product.meta?.barcode ?? 'product:${product.id}';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final media = MediaQuery.of(context);
    _galleryHeight = math.min(media.size.width, media.size.height * 0.55);

    return Scaffold(
      body: Observer(
        builder: (_) {
          final product = _store.display;
          final images = _store.images;
          return CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverAppBar(
                pinned: true,
                stretch: true,
                expandedHeight: _galleryHeight,
                backgroundColor: colors.background,
                surfaceTintColor: Colors.transparent,
                leadingWidth: 64,
                leading: Center(
                  child: _RoundButton(
                    icon: Icons.adaptive.arrow_back_rounded,
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
                title: ValueListenableBuilder(
                  valueListenable: _collapsed,
                  builder: (context, collapsed, child) => AnimatedOpacity(
                    opacity: collapsed ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: child,
                  ),
                  child: Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.navTitle(color: colors.text),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: ImageGallery(
                    expand: true,
                    images: images,
                    heroTag: productHeroTag(product.id),
                    placeholderUrl: widget.product.thumbnail,
                    onImageTap: (index) => _openImage(images, index),
                    imagePadding: EdgeInsets.fromLTRB(
                      Dimens.space32,
                      media.padding.top + kToolbarHeight,
                      Dimens.space32,
                      Dimens.space32 + Dimens.space8,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: Dimens.maxContentWidth,
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        Dimens.screenPadding,
                        Dimens.space24,
                        Dimens.screenPadding,
                        media.padding.bottom + Dimens.space32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Header(product: product),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _buildBody(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    final product = _store.product;
    if (product != null) {
      return _LoadedBody(
        key: const ValueKey('loaded'),
        product: product,
        reviews: _store.reviews,
        reviewsArePlaceholder: _store.reviewsArePlaceholder,
        qrData: _qrData(product),
        onOpenQr: (source) => _openQr(product, source),
      );
    }
    if (_store.error != null) {
      return Padding(
        key: const ValueKey('error'),
        padding: const EdgeInsets.only(top: Dimens.space24),
        child: ErrorView(error: _store.error, onRetry: _store.load),
      );
    }
    return const _BodyShimmer(key: ValueKey('loading'));
  }
}

/// A circular, frosted icon button that reads over photos and plain bars.
class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: FrostedSurface(
        showDivider: false,
        child: SizedBox.square(
          dimension: 40,
          child: IconButton(
            tooltip: tooltip,
            padding: EdgeInsets.zero,
            iconSize: 20,
            color: context.colors.text,
            icon: Icon(icon),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}

/// Brand, category, title, price and the three key facts.
class _Header extends StatelessWidget {
  const _Header({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final brand = product.brand;
    final discount = product.discountPercentage;
    final hasDiscount = discount != null && discount >= 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Dimens.space8,
          runSpacing: Dimens.space8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (brand != null)
              Text(
                brand.toUpperCase(),
                style: AppText.labelMedium(
                  color: colors.textTertiary,
                ).copyWith(letterSpacing: 0.8),
              ),
            if (product.category.isNotEmpty) _Tag(label: product.categoryLabel),
          ],
        ),
        const SizedBox(height: Dimens.space8),
        Text(product.title, style: AppText.headingLarge(color: colors.text)),
        const SizedBox(height: Dimens.space12),
        Row(
          children: [
            PriceText(price: product.price, large: true),
            if (hasDiscount) ...[
              const SizedBox(width: Dimens.space12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimens.space8,
                  vertical: Dimens.space2,
                ),
                decoration: BoxDecoration(
                  color: colors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(Dimens.radiusPill),
                ),
                child: Text(
                  'Save ${discount.round()}%',
                  style: AppText.labelMedium(color: colors.success),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: Dimens.space20),
        _FactsRow(product: product),
        const SizedBox(height: Dimens.space24),
        const _SectionTitle(title: 'About this item'),
        const SizedBox(height: Dimens.space8),
        Text(
          product.description,
          style: AppText.bodyMedium(color: colors.textSecondary),
        ),
      ],
    );
  }
}

/// Rating, availability and discount as three equal tiles.
class _FactsRow extends StatelessWidget {
  const _FactsRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final discount = product.discountPercentage;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: Dimens.space12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Dimens.radiusLarge),
        border: Border.all(color: colors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _Fact(
                label: 'Rating',
                semanticsLabel:
                    'Rated ${product.rating.toStringAsFixed(1)} out of 5',
                value: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 18, color: colors.rating),
                    const SizedBox(width: Dimens.space2),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: AppText.headingSmall(color: colors.text),
                    ),
                  ],
                ),
              ),
            ),
            VerticalDivider(width: 1, color: colors.border),
            Expanded(
              child: _Fact(
                label: product.inStock ? 'In Stock' : 'Out of Stock',
                semanticsLabel: product.inStock
                    ? 'Availability: In Stock, ${product.stock} left'
                    : 'Availability: Out of Stock',
                labelColor: product.inStock ? colors.success : colors.error,
                value: Text(
                  product.inStock ? '${product.stock} left' : 'None left',
                  style: AppText.headingSmall(color: colors.text),
                ),
              ),
            ),
            VerticalDivider(width: 1, color: colors.border),
            Expanded(
              child: _Fact(
                label: 'Discount',
                value: Text(
                  discount != null && discount >= 1
                      ? '-${discount.round()}%'
                      : 'None',
                  style: AppText.headingSmall(color: colors.text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({
    required this.label,
    required this.value,
    this.labelColor,
    this.semanticsLabel,
  });

  final String label;
  final Widget value;
  final Color? labelColor;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      excludeSemantics: semanticsLabel != null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          value,
          const SizedBox(height: Dimens.space2),
          Text(
            label,
            style: AppText.labelSmall(
              color: labelColor ?? context.colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.space8,
        vertical: Dimens.space2,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceHighlight,
        borderRadius: BorderRadius.circular(Dimens.radiusPill),
      ),
      child: Text(
        label,
        style: AppText.labelSmall(color: colors.textSecondary),
      ),
    );
  }
}

/// Reviews and the QR code, shown once the full product has loaded.
class _LoadedBody extends StatelessWidget {
  const _LoadedBody({
    required this.product,
    required this.reviews,
    required this.reviewsArePlaceholder,
    required this.qrData,
    required this.onOpenQr,
    super.key,
  });

  final Product product;
  final List<Review> reviews;
  final bool reviewsArePlaceholder;
  final String qrData;
  final ValueChanged<QrSource> onOpenQr;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Dimens.space32),
        const _SectionTitle(title: 'Reviews'),
        const SizedBox(height: Dimens.space12),
        _RatingSummary(
          rating: product.rating,
          reviewCount: reviews.length,
          placeholder: reviewsArePlaceholder,
        ),
        for (var i = 0; i < reviews.length; i++) ...[
          if (i > 0) const Divider(height: 1),
          ReviewTile(review: reviews[i]),
        ],
        const SizedBox(height: Dimens.space24),
        const _SectionTitle(title: 'QR code'),
        const SizedBox(height: Dimens.space12),
        QrCodeCard(
          qrCodeUrl: product.meta?.qrCode,
          qrData: qrData,
          onOpen: onOpenQr,
        ),
      ],
    );
  }
}

/// The overall rating in large type, with the review count.
class _RatingSummary extends StatelessWidget {
  const _RatingSummary({
    required this.rating,
    required this.reviewCount,
    required this.placeholder,
  });

  final double rating;
  final int reviewCount;
  final bool placeholder;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final countLabel = placeholder
        ? 'No reviews yet · showing samples'
        : reviewCount == 1
        ? '1 review'
        : '$reviewCount reviews';

    return Container(
      padding: const EdgeInsets.all(Dimens.space16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Dimens.radiusLarge),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Text(
            rating.toStringAsFixed(1),
            style: AppText.headingLarge(
              color: colors.text,
            ).copyWith(fontSize: 36, height: 1),
          ),
          const SizedBox(width: Dimens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RatingStars(rating: rating, size: 18, showValue: false),
                const SizedBox(height: Dimens.space4),
                Text(
                  'Overall rating · $countLabel',
                  style: AppText.labelMedium(color: colors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        title,
        style: AppText.headingMedium(color: context.colors.text),
      ),
    );
  }
}

class _BodyShimmer extends StatelessWidget {
  const _BodyShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: Dimens.space32),
          ShimmerBox(width: 120, height: 20),
          SizedBox(height: Dimens.space12),
          ShimmerBox(height: 76, radius: Dimens.radiusLarge),
          SizedBox(height: Dimens.space16),
          _ReviewShimmer(),
          _ReviewShimmer(),
          _ReviewShimmer(),
        ],
      ),
    );
  }
}

class _ReviewShimmer extends StatelessWidget {
  const _ReviewShimmer();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: Dimens.space16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 36, height: 36, radius: Dimens.radiusPill),
          SizedBox(width: Dimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 140, height: 12),
                SizedBox(height: Dimens.space8),
                ShimmerBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
