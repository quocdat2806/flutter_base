import 'dart:async';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:repositories/repositories.dart';

import 'file_cache_service.dart';

/// Keeps cached data from outliving the session that fetched it.
///
/// * Startup / app resume: drops expired JSON rows, and wipes private files
///   once they are older than [CacheTtl.privateFilesMaxAge].
/// * Logout / session expired: wipes user JSON (keeps `public.*`), private
///   files and the owner marker.
/// * [claimFor]: after sign-in, wipes again if the cache belongs to someone
///   else (a previous wipe failed half-way).
///
/// ```dart
/// final guard = SessionCacheGuard(...);
/// await guard.start(authManager.status);
/// // after login, before any screen reads the cache:
/// await guard.claimFor(profile.id);
/// ```
final class SessionCacheGuard {
  SessionCacheGuard({
    required JsonCache jsonCache,
    required CacheStore store,
    required FileCacheService files,
    required StorageService prefs,
    AppLogger? logger,
    DateTime Function()? clock,
  }) : _jsonCache = jsonCache,
       _store = store,
       _files = files,
       _prefs = prefs,
       _logger = logger,
       _clock = clock ?? DateTime.now;

  final JsonCache _jsonCache;
  final CacheStore _store;
  final FileCacheService _files;
  final StorageService _prefs;
  final AppLogger? _logger;
  final DateTime Function() _clock;

  StreamSubscription<AuthStatus>? _authSub;
  AppLifecycleListener? _lifecycle;

  /// Runs maintenance now and on every resume, and wipes on sign-out.
  Future<void> start(Stream<AuthStatus> status) async {
    await runMaintenance();
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(runMaintenance()));
    _authSub = status.listen((s) {
      if (s is Unauthenticated) unawaited(clearUserData());
    });
  }

  Future<void> dispose() async {
    _lifecycle?.dispose();
    await _authSub?.cancel();
  }

  Future<void> runMaintenance() async {
    await _try('purge expired cache', _store.purgeExpired);
    await _try('expire private files', () async {
      final now = _clock().millisecondsSinceEpoch;
      final last = await _prefs.get<int>(PrefKeys.privateFilesClearedAt);
      if (last != null &&
          now - last < CacheTtl.privateFilesMaxAge.inMilliseconds) {
        return;
      }
      await _files.clearPrivate();
      await _prefs.set(PrefKeys.privateFilesClearedAt, now);
    });
  }

  /// Wipes everything that belongs to the user. Each step runs even if an
  /// earlier one failed.
  Future<void> clearUserData() async {
    _jsonCache.resetSession();
    await _try(
      'clear JSON cache',
      () => _store.clear(keepPrefix: CacheKeys.publicPrefix),
    );
    await _try('clear private files', _files.clearPrivate);
    await _try('clear cache owner', () => _prefs.remove(PrefKeys.cacheOwner));
  }

  /// Marks the cache as belonging to [userId], wiping it first if it was
  /// written for anyone else.
  Future<void> claimFor(String userId) async {
    final owner = await _prefs.get<String>(PrefKeys.cacheOwner);
    if (owner == userId) return;
    await clearUserData();
    await _prefs.set(PrefKeys.cacheOwner, userId);
  }

  Future<void> _try(String what, Future<void> Function() body) async {
    try {
      await body();
    } catch (e, st) {
      _logger?.e('SessionCacheGuard: $what failed', error: e, stackTrace: st);
    }
  }
}
