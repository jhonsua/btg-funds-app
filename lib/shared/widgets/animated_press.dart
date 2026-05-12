import 'package:flutter/material.dart';

/// Wrapper de press feedback premium para cards y botones interactivos.
///
/// Aplica scale 0.98 + opacity 0.92 durante el press, animado en 100ms con
/// `Curves.easeOut`. Si `onTap` es `null`, los gestures de press se desactivan
/// (no consume el gesto, permitiendo que padres lo reciban).
class AnimatedPress extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const AnimatedPress({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<AnimatedPress> createState() => _AnimatedPressState();
}

class _AnimatedPressState extends State<AnimatedPress> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:
          widget.onTap == null ? null : (_) => setState(() => _pressed = true),
      onTapUp:
          widget.onTap == null ? null : (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: widget.child,
        ),
      ),
    );
  }
}
