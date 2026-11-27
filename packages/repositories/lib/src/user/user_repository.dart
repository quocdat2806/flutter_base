import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:core/core.dart';

import '../base/base_repository.dart';
import '../cache/cache_policy.dart';
import '../cache/json_cache.dart';
import 'user_profile.dart';

/// Profile of the signed-in user. Depend on this interface in BLoCs /
/// use cases; inject [UserRepositoryImpl] (or a fake) at the composition
/// root.
abstract interface class UserRepository {
  /// Emits on every successful fetch / update – lets several screens stay in
  /// sync (avatar in drawer, profile screen…).
  Stream<UserProfile> get changes;

  Future<Result<UserProfile>> getProfile({
    CachePolicy policy = CachePolicy.networkFirst,
  });

  Future<Result<UserProfile>> updateProfile(UpdateProfileRequest request);

  Future<Result<UserProfile>> uploadAvatar(
    String filePath, {
    ProgressCallback? onProgress,
  });

  /// Drop cached profile (call on logout).
  Future<void> clear();
}

/// Endpoint paths for [UserRepositoryImpl].
final class UserEndpoints {
  const UserEndpoints({
    this.me = '/users/me',
    this.avatar = '/users/me/avatar',
  });

  final String me;
  final String avatar;
}

final class UserRepositoryImpl extends BaseRepository
    implements UserRepository {
  UserRepositoryImpl({
    required ApiClient client,
    required JsonCache cache,
    this.endpoints = const UserEndpoints(),
    this.ttl = const Duration(minutes: 10),
    super.logger,
  }) : _client = client,
       _cache = cache;

  final ApiClient _client;
  final JsonCache _cache;
  final UserEndpoints endpoints;
  final Duration ttl;

  static const _cacheKey = CacheKeys.userMe;
  final _changes = StreamController<UserProfile>.broadcast();

  @override
  Stream<UserProfile> get changes => _changes.stream;

  @override
  Future<Result<UserProfile>> getProfile({
    CachePolicy policy = CachePolicy.networkFirst,
  }) => guard(() async {
    final profile = await _cache.fetch<UserProfile>(
      key: _cacheKey,
      policy: policy,
      ttl: ttl,
      fetch: () => _client.get(
        endpoints.me,
        decoder: Decoders.object(UserProfile.fromJson),
      ),
      encode: (p) => p.toJson(),
      decode: (json) => UserProfile.fromJson(json! as JsonMap),
    );
    _changes.add(profile);
    return profile;
  });

  @override
  Future<Result<UserProfile>> updateProfile(UpdateProfileRequest request) =>
      _store(
        () => _client.patch(
          endpoints.me,
          data: request.toJson(),
          decoder: Decoders.object(UserProfile.fromJson),
        ),
      );

  @override
  Future<Result<UserProfile>> uploadAvatar(
    String filePath, {
    ProgressCallback? onProgress,
  }) => _store(
    () async => _client.upload(
      endpoints.avatar,
      data: FormData.fromMap({'file': await MultipartFile.fromFile(filePath)}),
      onSendProgress: onProgress,
      decoder: Decoders.object(UserProfile.fromJson),
    ),
  );

  @override
  Future<void> clear() => _cache.invalidate(_cacheKey);

  /// Runs a mutating call, refreshes the cache and notifies listeners.
  Future<Result<UserProfile>> _store(Future<UserProfile> Function() call) =>
      guard(() async {
        final session = _cache.session;
        final profile = await call();
        await _cache.write(_cacheKey, profile.toJson(), session: session);
        _changes.add(profile);
        return profile;
      });

  Future<void> dispose() => _changes.close();
}
