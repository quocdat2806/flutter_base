import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('guard captures success and failure', () async {
      expect(await Result.guard(() => 1), const Success(1));
      final failed = await Result.guard<int>(
        () => throw const NotFoundException(),
      );
      expect(failed.errorOrNull, isA<NotFoundException>());
    });

    test('guard wraps foreign errors in UnknownException', () async {
      final r = await Result.guard<int>(() => throw StateError('boom'));
      expect(r.errorOrNull, isA<UnknownException>());
    });

    test('map / flatMap / fold', () async {
      const Result<int> ok = Success(2);
      expect(ok.map((v) => v * 2).valueOrNull, 4);
      expect((await ok.flatMap((v) => Success('$v'))).valueOrNull, '2');
      const Result<int> ko = Failure(ForbiddenException());
      expect(ko.map((v) => v * 2).isFailure, isTrue);
      expect(ko.fold((_) => 'ok', (e) => 'err'), 'err');
      expect(ko.getOrElse((_) => -1), -1);
      expect(() => ko.valueOrThrow, throwsA(isA<ForbiddenException>()));
    });
  });

  test('ValidationException.errorFor', () {
    const e = ValidationException(
      'bad',
      fieldErrors: {
        'phone': ['invalid'],
      },
    );
    expect(e.errorFor('phone'), 'invalid');
    expect(e.errorFor('email'), isNull);
  });

  group('Paginated', () {
    test('hasMore from total and merge', () {
      const p1 = Paginated(items: [1, 2], page: 1, pageSize: 2, total: 3);
      expect(p1.hasMore, isTrue);
      final merged = p1.merge(
        const Paginated(items: [3], page: 2, pageSize: 2, total: 3),
      );
      expect(merged.items, [1, 2, 3]);
      expect(merged.hasMore, isFalse);
    });
  });

  group('generated code', () {
    test('Result equality and toString', () {
      expect(const Success(1), const Success(1));
      expect(const Success(1), isNot(const Success(2)));
      expect(
        const Result<int>.failure(NotFoundException()),
        const Failure<int>(NotFoundException()),
      );
      expect(const Success(1).toString(), contains('1'));
    });

    test('Paginated equality, copyWith, unmodifiable items', () {
      final a = Paginated(items: [1, 2], page: 1, pageSize: 2);
      expect(a, Paginated(items: [1, 2], page: 1, pageSize: 2));
      expect(a.copyWith(page: 2).page, 2);
      expect(() => a.items.add(3), throwsUnsupportedError);
      expect(Paginated<int>.empty().hasMore, isFalse);
    });

    test('Paginated JSON round-trip', () {
      final page = Paginated<String>.fromJson({
        'items': ['a', 'b'],
        'page': 2,
        'pageSize': 2,
        'total': 5,
      }, (e) => e! as String);
      expect(page.items, ['a', 'b']);
      expect(page.hasMore, isTrue);
      expect(page.toJson((e) => e), {
        'items': ['a', 'b'],
        'page': 2,
        'pageSize': 2,
        'total': 5,
        'hasMore': null,
      });
    });

    test('AppConfig equality and copyWith', () {
      const a = AppConfig(flavor: Flavor.dev, apiBaseUrl: 'https://x');
      expect(a, const AppConfig(flavor: Flavor.dev, apiBaseUrl: 'https://x'));
      final b = a.copyWith(apiBaseUrl: 'https://y');
      expect(b.apiBaseUrl, 'https://y');
      expect(b.flavor, Flavor.dev);
      expect(b, isNot(a));
    });
  });

  test('AppConfig defaults by flavor', () {
    const prod = AppConfig(flavor: Flavor.prod, apiBaseUrl: 'https://x');
    expect(prod.enableNetworkLogs, isFalse);
    expect(prod.enableAnalytics, isTrue);
    expect(Flavor.fromName('nope'), Flavor.dev);
  });

  test('ConsoleLogger formats lines and honours minLevel', () {
    final lines = <String>[];
    final logger = ConsoleLogger(minLevel: LogLevel.info, sink: lines.add);
    logger.d('hidden');
    logger.w('restore failed', tag: 'auth', error: 'boom');
    expect(lines, ['W [auth] restore failed | boom']);
    const NoopLogger().e('ignored');
  });

  test('core stays pure Dart: lib/ imports no Flutter or dart:ui', () {
    final offenders = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where(
          (f) => f.readAsLinesSync().any(
            (line) => RegExp(
              r'''^\s*(import|export)\s+['"](package:flutter|dart:ui)''',
            ).hasMatch(line),
          ),
        )
        .map((f) => f.path)
        .toList();
    expect(offenders, isEmpty);
  });
}
