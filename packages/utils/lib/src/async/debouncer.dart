import 'dart:async';

/// Delays [run] until no call happened for [duration]. Typical use: search
/// as you type.
class Debouncer {
  Debouncer({this.duration = const Duration(milliseconds: 400)});

  final Duration duration;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  bool get isPending => _timer?.isActive ?? false;

  void cancel() => _timer?.cancel();

  void dispose() => cancel();
}

/// Executes at most once per [duration]; extra calls are dropped. Typical
/// use: guarding submit buttons against double taps.
class Throttler {
  Throttler({this.duration = const Duration(milliseconds: 800)});

  final Duration duration;
  DateTime? _last;

  /// Returns `true` when [action] was executed.
  bool run(void Function() action) {
    final now = DateTime.now();
    if (_last != null && now.difference(_last!) < duration) return false;
    _last = now;
    action();
    return true;
  }

  void reset() => _last = null;
}

/// Retries [task] with exponential backoff while [retryIf] returns true.
Future<T> retry<T>(
  Future<T> Function() task, {
  int maxAttempts = 3,
  Duration initialDelay = const Duration(milliseconds: 300),
  double factor = 2,
  bool Function(Object error)? retryIf,
}) async {
  assert(maxAttempts > 0, 'maxAttempts must be positive');
  var delay = initialDelay;
  for (var attempt = 1; ; attempt++) {
    try {
      return await task();
    } catch (e) {
      final canRetry = attempt < maxAttempts && (retryIf?.call(e) ?? true);
      if (!canRetry) rethrow;
      await Future<void>.delayed(delay);
      delay *= factor;
    }
  }
}
