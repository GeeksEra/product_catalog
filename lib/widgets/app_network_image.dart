import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/dimens.dart';
import 'package:product_catalog/widgets/shimmer_box.dart';

/// A cached network image with a shimmer placeholder and an error fallback.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.url,
    this.fit = BoxFit.cover,
    this.cacheSize,
    this.placeholderUrl,
    super.key,
  });

  final String url;
  final BoxFit fit;

  /// Logical size used to decode a smaller bitmap, for thumbnails.
  final double? cacheSize;

  /// Shown while [url] loads, if set. The detail gallery passes the list
  /// thumbnail, which is already cached, so the Hero flight never shows an
  /// empty frame.
  final String? placeholderUrl;

  @override
  Widget build(BuildContext context) {
    final pixels = cacheSize == null
        ? null
        : (cacheSize! * MediaQuery.devicePixelRatioOf(context)).round();
    final placeholder = placeholderUrl;

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      memCacheWidth: pixels,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (context, _) => placeholder != null && placeholder != url
          ? AppNetworkImage(url: placeholder, fit: fit)
          : const AppShimmer(child: ShimmerBox(radius: 0)),
      errorWidget: (context, _, _) => ColoredBox(
        color: context.colors.surfaceHighlight,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: Dimens.iconMedium,
            color: context.colors.textTertiary,
          ),
        ),
      ),
    );
  }
}
