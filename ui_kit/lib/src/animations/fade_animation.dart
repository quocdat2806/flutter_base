import 'package:flutter/widgets.dart';

import '../tokens/app_motion.dart';
import 'entrance_animation.dart';

/// Fades [child] in once when first built.
class FadeInAnimation extends StatelessWidget {
  const FadeInAnimation({
    super.key,
    required this.child,
    this.duration = AppMotion.medium2,
    this.delay = Duration.zero,
    this.curve = AppMotion.emphasizedDecelerate,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return EntranceAnimation(
      duration: duration,
      delay: delay,
      curve: curve,
      builder: (animation) => FadeTransition(opacity: animation, child: child),
    );
  }
}
