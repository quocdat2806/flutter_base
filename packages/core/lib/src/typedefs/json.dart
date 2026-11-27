// packages/core/lib/src/typedefs/typedefs.dart
// Result<T> / AsyncResult<T> live in error/failure.dart.

// ══════════════════════════════
// Common typedefs
// ══════════════════════════════
typedef JsonMap = Map<String, dynamic>;
typedef JsonList = List<Map<String, dynamic>>;
typedef FromJson<T> = T Function(JsonMap json);

