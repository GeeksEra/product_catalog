import 'package:flutter/material.dart';

/// Shrinks its child slightly while pressed. Ported from the BuddyBoss
/// `ScaleTapWidget`, keeping only the scale effect.
class ScaleTap extends StatefulWidget {
  const ScaleTap({
    required this.child,
    required this.onTap,
    this.scale = 0.97,
    this.duration = const Duration(milliseconds: 120),
    super.key,
  });

  final Widget child;
  final VoidCallback onTap;
  final double scale;
  final Duration duration;

  @override
  State<ScaleTap> createState() => _ScaleTapState();
}

class _ScaleTapState extends State<ScaleTap> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: AnimatedScale(
          scale: _pressed ? widget.scale : 1,
          duration: widget.duration,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
