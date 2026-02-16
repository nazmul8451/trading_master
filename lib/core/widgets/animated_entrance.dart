import 'package:flutter/material.dart';

class AnimatedEntrance extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset offset;

  const AnimatedEntrance({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.offset = const Offset(0.0, 0.2), // Slide up from slightly below
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: duration,
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(
              offset.dx *
                  (1 - value) *
                  100, // Reduced from 200 for subtle effect
              offset.dy * (1 - value) * 100,
            ),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: child,
      ),
    );
  }
}
