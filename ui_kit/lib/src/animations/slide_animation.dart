import 'package:flutter/widgets.dart';

import '../tokens/app_motion.dart';
import 'entrance_animation.dart';

/// Slides and fades [child] in from [begin] (fraction of its size).
/// Default: from 10% below.
class SlideInAnimation extends StatelessWidget {
  const SlideInAnimation({
    super.key,
    required this.child,
    this.begin = const Offset(0, 0.1),
    this.duration = AppMotion.medium4,
    this.delay = Duration.zero,
    this.curve = AppMotion.emphasizedDecelerate,
  });

  final Widget child;
  final Offset begin;
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
        child: SlideTransition(
          position: Tween(begin: begin, end: Offset.zero).animate(animation),
          child: child,
        ),
      ),
    );
  }
}
