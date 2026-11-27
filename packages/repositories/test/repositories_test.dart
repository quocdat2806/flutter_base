import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repositories/repositories.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:storage/storage.dart';

void main() {
  setUp(
    () => SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty(),
  );

  group('JsonCache', () {
    late DateTime now;
    late JsonCache cache;

    setUp(() {
      now = DateTime(2026, 1, 1, 12);
      cache = JsonCache(SharedPreferencesStorageService(), clock: () => now);
    });

    Future<int> run(CachePolicy policy, Future<int> Function() fetch) =>
        cache.fetch<int>(
          key: 'k',
          policy: policy,
          ttl: const Duration(minutes: 5),
          fetch: fetch,
          encode: (v) => v,
          decode: (j) => j! as int,
        );

    test('cacheFirst serves fresh cache without network', () async {
      expect(await run(CachePolicy.cacheFirst, () async => 1), 1);
      expect(await run(CachePolicy.cacheFirst, () async => 2), 1);
      now = now.add(const Duration(minutes: 6));
      expect(await run(CachePolicy.cacheFirst, () async => 3), 3);
    });

    test('networkFirst falls back to stale cache only when offline', () async {
      await run(CachePolicy.networkOnly, () async => 1);
      now = now.add(const Duration(days: 1));
      expect(
        await run(
          CachePolicy.networkFirst,
          () async => throw const NetworkException(),
        ),
        1,
      );
      await expectLater(
        run(
          CachePolicy.networkFirst,
          () async => throw const UnauthorizedException(),
        ),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('cacheOnly miss throws StorageException', () async {
      await expectLater(
        run(CachePolicy.cacheOnly, () async => 1),
        throwsA(isA<StorageException>()),
      );
    });
  });

  test('UserProfile json roundtrip', () {
    final p = UserProfile.fromJson({
      'id': 7,
      'full_name': 'Nguyễn Văn An',
      'phone': '0912345678',
      'date_of_birth': '1990-05-02',
      'gender': 'MALE',
    });
    expect(p.id, '7');
    expect(p.gender, Gender.male);
    expect(UserProfile.fromJson(p.toJson()), p);
    expect(const UpdateProfileRequest(fullName: 'A').toJson(), {
      'fullName': 'A',
    });
  });

  test('BaseRepository.guard maps errors', () async {
    final repo = _Repo();
    expect((await repo.guard(() => 1)).valueOrNull, 1);
    expect(
      (await repo.guard<int>(
        () => throw const NotFoundException(),
      )).errorOrNull,
      isA<NotFoundException>(),
    );
    expect(
      (await repo.guard<int>(() => throw StateError('x'))).errorOrNull,
      isA<UnknownException>(),
    );
  });

  test('UserRepositoryImpl is constructible with ApiClient', () {
    final repo = UserRepositoryImpl(
      client: ApiClient(config: const ApiClientConfig(baseUrl: 'https://x')),
      cache: JsonCache(SharedPreferencesStorageService()),
    );
    expect(repo, isA<UserRepository>());
  });
}

final class _Repo extends BaseRepository {}
