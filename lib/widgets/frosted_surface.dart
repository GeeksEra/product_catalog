import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/dimens.dart';

/// A translucent, blurred bar background, like iOS navigation and tab bars.
///
/// Content that scrolls underneath shows through softly. [showDivider] draws
/// a hairline on the [dividerEdge], which bars use to separate themselves from
/// the content once it scrolls beneath them.
class FrostedSurface extends StatelessWidget {
  const FrostedSurface({
    required this.child,
    this.showDivider = true,
    this.dividerEdge = VerticalDirection.down,
    this.color,
    super.key,
  });

  final Widget child;
  final bool showDivider;

  /// [VerticalDirection.down] puts the hairline at the bottom (navigation
  /// bars); [VerticalDirection.up] puts it at the top (tab bars).
  final VerticalDirection dividerEdge;

  /// A solid fill instead of the translucent background, for bars that carry
  /// the brand color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final side = BorderSide(
      color: showDivider ? colors.border : colors.border.withValues(alpha: 0),
      width: Dimens.borderThin,
    );

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: color ?? colors.background.withValues(alpha: 0.86),
          // A foreground border takes no layout space, so the hairline never
          // pushes the bar's content.
          foregroundDecoration: BoxDecoration(
            border: dividerEdge == VerticalDirection.down
                ? Border(bottom: side)
                : Border(top: side),
          ),
          child: child,
        ),
      ),
    );
  }
}
