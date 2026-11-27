// packages/core/lib/src/events/app_event.dart

/// Base class cho tất cả domain events.
abstract class AppEvent {
  final DateTime timestamp;

  AppEvent({DateTime? timestamp}) : timestamp = timestamp ?? DateTime.now();
}
