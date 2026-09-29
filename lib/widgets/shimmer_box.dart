import 'package:flutter/material.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/dimens.dart';
import 'package:shimmer/shimmer.dart';

/// Wraps skeleton shapes in the shared shimmer animation.
class AppShimmer extends StatelessWidget {
  const AppShimmer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = context.colors.surfaceHighlight;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: base.withValues(alpha: 0.5),
      child: child,
    );
  }
}

/// A solid placeholder block. Place it inside an [AppShimmer] to animate it.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    this.width,
    this.height,
    this.radius = Dimens.radiusSmall,
    super.key,
  });

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.surfaceHighlight,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
