import 'dart:async';

import 'package:flutter/widgets.dart';

/// Runs a one-shot 0→1 animation after [delay] and hands it to [builder].
/// Skips straight to the end when the platform requests reduced motion.
class EntranceAnimation extends StatefulWidget {
  const EntranceAnimation({
    super.key,
    required this.builder,
    required this.duration,
    this.delay = Duration.zero,
    this.curve = Curves.linear,
  });

  final Widget Function(Animation<double> animation) builder;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  @override
  State<EntranceAnimation> createState() => _EntranceAnimationState();
}

class _EntranceAnimationState extends State<EntranceAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
  );
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _controller.value = 1;
    } else if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_animation);
}
