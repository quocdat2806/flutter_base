import 'dart:convert';

import 'package:core/core.dart';

import '../../error/failure.dart';

/// Key-value storage contract, implemented by:
/// * [SharedPreferencesStorageService] – settings, flags, small cache.
/// * [SecureStorageService] – tokens, PINs, PII (Keychain / Keystore).
///
/// For structured / queryable data use `DatabaseService` instead.
/// Pick the implementation at the composition root; anything sensitive must
/// get a [SecureStorageService] instance.
///
/// Typed getters return `null` when the key is missing or holds a value of
/// another type. Backend failures surface as [CacheFailure].
abstract interface class StorageService {
  /// Reads [key] as [T]. Returns `null` when the key is missing or holds a
  /// value that isn't a [T].
  ///
  /// ```dart
  /// final count = await storage.get<int>('launch_count');
  /// ```
  Future<T?> get<T>(String key);

  /// Writes [value] under [key]. Supported types: `String`, `bool`, `int`,
  /// `double`, `List<String>`. Anything else throws [ArgumentError]; store
  /// objects with `setJson` instead.
  Future<void> set<T extends Object>(String key, T value);

  Future<bool> containsKey(String key);
  Future<void> remove(String key);

  /// Clears every key owned by this service. When [allowList] is given only
  /// those keys are removed.
  Future<void> clear({Set<String>? allowList});
}

/// A [StorageService] that encrypts at rest (Keychain / Keystore).
///
/// Code that persists secrets should require this type instead of
/// [StorageService], so passing a plain-text store doesn't compile.
abstract interface class SecureStorage implements StorageService {}

/// JSON helpers available on every [StorageService].
extension StorageServiceJson on StorageService {
  Future<JsonMap?> getJson(String key) async {
    final raw = await get<String>(key);
    if (raw == null) return null;
    Object? cause;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is JsonMap) return decoded;
      cause = 'expected a JSON object, got ${decoded.runtimeType}';
    } on FormatException catch (e) {
      cause = e.message;
    }
    // Corrupted entry: drop it so the app can recover.
    await remove(key);
    throw CacheFailure('Corrupted JSON at "$key": $cause');
  }

  Future<void> setJson(String key, JsonMap value) =>
      set(key, jsonEncode(value));

  Future<T?> getObject<T>(String key, FromJson<T> fromJson) async {
    final json = await getJson(key);
    return json == null ? null : fromJson(json);
  }
}

/// Throws [ArgumentError] unless [value] is a type [StorageService.set]
/// supports. Shared by the implementations; not exported.
void checkStorageValue(String key, Object value) {
  if (value is String ||
      value is bool ||
      value is int ||
      value is double ||
      value is List<String>) {
    return;
  }
  throw ArgumentError.value(
    value,
    key,
    'Unsupported type ${value.runtimeType}; use setJson for objects',
  );
}

/// Narrows a raw stored [value] to [T], converting what the backends lose:
/// `int` read as `double`, and `List<dynamic>` read as `List<String>`.
/// Returns `null` when it doesn't fit. Shared by the implementations.
T? coerceStorageValue<T>(Object? value) {
  if (value is T) return value;
  if (value is int && 0.0 is T) return value.toDouble() as T;
  if (value is List && <String>[] is T && value.every((e) => e is String)) {
    return List<String>.from(value) as T;
  }
  return null;
}

/// Runs [body] and rethrows any backend error as [CacheFailure], keeping the
/// original stack trace. [Failure]s (including ones thrown by caller code
/// inside a transaction) and [ArgumentError]s pass through untouched.
/// [mapError] lets a backend return a more specific failure for an error it
/// recognises (e.g. [UniqueConstraintFailure]). Shared by the implementations.
Future<T> guardStorage<T>(
  String backend,
  String op,
  String key,
  Future<T> Function() body, {
  Failure? Function(Object error, String message)? mapError,
}) async {
  try {
    return await body();
  } on Failure {
    rethrow;
  } on ArgumentError {
    rethrow;
  } catch (e, st) {
    final message = '$backend $op failed for "$key": $e';
    Error.throwWithStackTrace(
      mapError?.call(e, message) ?? CacheFailure(message),
      st,
    );
  }
}
