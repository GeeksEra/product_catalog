import 'package:flutter/material.dart';

/// Fades and slides the first few items of a freshly loaded list in, with a
/// short stagger.
///
/// Items past [animatedCount] appear without animation. Cards built while the
/// user scrolls or flings would otherwise start invisible and flash blank.
class FadeInItem extends StatelessWidget {
  const FadeInItem({
    required this.index,
    required this.child,
    this.animate = true,
    this.animatedCount = 8,
    super.key,
  });

  final int index;

  /// False for items that were already revealed once, so scrolling back up
  /// doesn't replay the fade.
  final bool animate;

  /// How many items from the top of the list animate.
  final int animatedCount;
  final Widget child;

  static const Duration _itemDuration = Duration(milliseconds: 200);
  static const Duration _stagger = Duration(milliseconds: 40);

  @override
  Widget build(BuildContext context) {
    if (!animate || index >= animatedCount) return child;
    final delay = _stagger * index;
    final total = delay + _itemDuration;
    final start = delay.inMicroseconds / total.inMicroseconds;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: Curves.easeOut),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
