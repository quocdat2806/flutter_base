import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:storage/storage.dart';

/// Same behaviour contract for every [CacheStore] implementation.
void contract(
  String name,
  Future<CacheStore> Function(DateTime Function() clock) create,
) {
  group(name, () {
    late DateTime now;
    late CacheStore s;
    setUp(() async {
      now = DateTime(2026, 1, 1, 8);
      s = await create(() => now);
    });

    test('write / read / overwrite', () async {
      expect(await s.read('a'), isNull);
      await s.write('a', '{"v":1}');
      final r = await s.read('a');
      expect(r!.value, '{"v":1}');
      expect(r.savedAt, now);
      expect(r.expiresAt, isNull);

      now = now.add(const Duration(minutes: 1));
      await s.write('a', '{"v":2}');
      expect((await s.read('a'))!.value, '{"v":2}');
    });

    test('read hides records past maxAge, purgeExpired deletes them', () async {
      await s.write('short', '1', maxAge: const Duration(hours: 1));
      await s.write('long', '2', maxAge: const Duration(hours: 12));
      await s.write('forever', '3');

      now = now.add(const Duration(hours: 1));
      expect(await s.read('short'), isNull);
      expect(await s.read('long'), isNotNull);

      expect(await s.purgeExpired(), 1);
      expect(await s.purgeExpired(), 0);
      expect(await s.read('forever'), isNotNull);
    });

    test('remove and removeWhere(prefix) treat _ and % literally', () async {
      for (final k in ['user.me', 'user_me', 'userXme', 'a%b.1', 'axb.1']) {
        await s.write(k, '1');
      }
      await s.remove('userXme');
      expect(await s.read('userXme'), isNull);

      await s.removeWhere(prefix: 'user_');
      expect(await s.read('user_me'), isNull);
      expect(await s.read('user.me'), isNotNull);

      await s.removeWhere(prefix: 'a%b');
      expect(await s.read('a%b.1'), isNull);
      expect(await s.read('axb.1'), isNotNull);
    });

    test('clear wipes all, or all but keepPrefix', () async {
      await s.write('public.doctor.list', '1');
      await s.write('user.me', '2');
      await s.clear(keepPrefix: 'public.');
      expect(await s.read('user.me'), isNull);
      expect(await s.read('public.doctor.list'), isNotNull);

      await s.clear();
      expect(await s.read('public.doctor.list'), isNull);
    });
  });
}

void main() {
  sqfliteFfiInit();

  contract(
    'SqfliteCacheStore',
    (clock) async => SqfliteCacheStore(
      await openAppDatabase(
        name: inMemoryDatabasePath,
        factory: databaseFactoryFfiNoIsolate,
      ),
      clock: clock,
    ),
  );

  contract('MemoryCacheStore', (clock) async => MemoryCacheStore(clock: clock));
}
