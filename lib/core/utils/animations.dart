import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Animation durations following Material Design 3
class AnimationDurations {
  static const Duration short = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration long = Duration(milliseconds: 350);
  static const Duration extraLong = Duration(milliseconds: 500);
}

/// Animation curves following Material Design 3
class AnimationCurves {
  static const Curve standard = Curves.easeInOut;
  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve decelerated = Curves.easeOut;
  static const Curve accelerated = Curves.easeIn;
}

/// Micro-interaction utilities
class MicroInteractions {
  /// Standard button press animation
  static void buttonPress(BuildContext context) {
    HapticFeedback.lightImpact();
  }

  /// Heavy interaction feedback
  static void heavyInteraction(BuildContext context) {
    HapticFeedback.mediumImpact();
  }

  /// Selection feedback
  static void selection(BuildContext context) {
    HapticFeedback.selectionClick();
  }

  /// Success feedback
  static void success(BuildContext context) {
    HapticFeedback.mediumImpact();
  }

  /// Error feedback
  static void error(BuildContext context) {
    HapticFeedback.heavyImpact();
  }
}

/// Fade in animation widget
class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const FadeInAnimation({
    super.key,
    required this.child,
    this.duration = AnimationDurations.medium,
    this.curve = AnimationCurves.standard,
  });

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

/// Scale animation on tap
class ScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  const ScaleOnTap({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.95,
  });

  @override
  State<ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<ScaleOnTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationDurations.short,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.standard),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    MicroInteractions.buttonPress(context);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse().then((_) {
      widget.onTap?.call();
    });
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

