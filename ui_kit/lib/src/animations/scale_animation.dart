import 'package:flutter/widgets.dart';

import '../tokens/app_motion.dart';
import 'entrance_animation.dart';

/// Scales and fades [child] in from [begin] scale.
class ScaleInAnimation extends StatelessWidget {
  const ScaleInAnimation({
    super.key,
    required this.child,
    this.begin = 0.8,
    this.duration = AppMotion.medium2,
    this.delay = Duration.zero,
    this.curve = AppMotion.emphasizedDecelerate,
  });

  final Widget child;
  final double begin;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return EntranceAnimation(
      duration: duration,
      delay: delay,
      curve: curve,
      builder: (animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: begin, end: 1.0).animate(animation),
          child: child,
        ),
      ),
    );
  }
}
