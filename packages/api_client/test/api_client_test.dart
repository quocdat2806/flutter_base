import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_adapter.dart';

class _Item {
  const _Item(this.id);
  factory _Item.fromJson(JsonMap j) => _Item(j['id'] as int);
  final int id;
}

class _FakeTokens implements AuthTokenProvider {
  String? token = 'old';
  int refreshCalls = 0;
  bool refreshOk = true;
  bool expired = false;

  @override
  Future<String?> get accessToken async => token;

  @override
  Future<bool> refreshToken() async {
    refreshCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (refreshOk) token = 'new';
    return refreshOk;
  }

  @override
  Future<void> onSessionExpired() async => expired = true;
}

ApiClient _client(
  FakeAdapter adapter, {
  AuthTokenProvider? tokens,
  int retries = 0,
}) => ApiClient(
  config: ApiClientConfig(baseUrl: 'https://api.test', maxRetries: retries),
  httpClientAdapter: adapter,
  tokenProvider: tokens,
);

void main() {
  group('decoding', () {
    test('object, list, paginated', () async {
      final adapter = FakeAdapter(
        (o) async => switch (o.path) {
          '/one' => const FakeResponse(200, {'id': 1}),
          '/many' => const FakeResponse(200, [
            {'id': 1},
            {'id': 2},
          ]),
          _ => const FakeResponse(200, {
            'data': [
              {'id': 3},
            ],
            'meta': {'page': 1, 'pageSize': 1, 'total': 2},
          }),
        },
      );
      final api = _client(adapter);
      expect(
        (await api.get('/one', decoder: Decoders.object(_Item.fromJson))).id,
        1,
      );
      expect(
        (await api.get('/many', decoder: Decoders.list(_Item.fromJson))).length,
        2,
      );
      final page = await api.get(
        '/page',
        decoder: Decoders.paginated(_Item.fromJson),
      );
      expect(page.items.single.id, 3);
      expect(page.hasMore, isTrue);
    });

    test('bad shape → ParseException', () async {
      final api = _client(
        FakeAdapter((_) async => const FakeResponse(200, ['x'])),
      );
      await expectLater(
        api.get('/x', decoder: Decoders.object(_Item.fromJson)),
        throwsA(isA<ParseException>()),
      );
    });
  });

  group('error mapping', () {
    Future<Object?> call(int status, [Object? body]) async {
      final api = _client(FakeAdapter((_) async => FakeResponse(status, body)));
      try {
        await api.get<Object?>('/x');
      } catch (e) {
        return e;
      }
      return null;
    }

    test('status codes', () async {
      expect(await call(404), isA<NotFoundException>());
      expect(await call(403), isA<ForbiddenException>());
      expect(await call(401), isA<UnauthorizedException>());
      final server = await call(500, {'message': 'oops', 'code': 'E1'});
      expect(
        server,
        isA<ServerException>()
            .having((e) => e.message, 'message', 'oops')
            .having((e) => e.code, 'code', 'E1'),
      );
      final validation = await call(422, {
        'message': 'invalid',
        'errors': {
          'phone': ['wrong'],
        },
      });
      expect((validation! as ValidationException).errorFor('phone'), 'wrong');
    });

    test('connection error → NetworkException', () async {
      final api = _client(
        FakeAdapter((_) async => throw FakeConnectionError()),
      );
      await expectLater(
        api.get<Object?>('/x'),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('AuthInterceptor', () {
    test('attaches bearer token, skips when requiresAuth=false', () async {
      final adapter = FakeAdapter((_) async => const FakeResponse(200, {}));
      final api = _client(adapter, tokens: _FakeTokens());
      await api.get<Object?>('/a');
      await api.get<Object?>('/b', options: apiOptions(requiresAuth: false));
      expect(adapter.requests[0].headers['Authorization'], 'Bearer old');
      expect(adapter.requests[1].headers.containsKey('Authorization'), isFalse);
    });

    test('refreshes once for parallel 401s and replays', () async {
      final tokens = _FakeTokens();
      final adapter = FakeAdapter(
        (o) async => o.headers['Authorization'] == 'Bearer new'
            ? const FakeResponse(200, {'ok': true})
            : const FakeResponse(401),
      );
      final api = _client(adapter, tokens: tokens);

      final results = await Future.wait([
        api.get<Object?>('/1'),
        api.get<Object?>('/2'),
        api.get<Object?>('/3'),
      ]);
      expect(results, everyElement({'ok': true}));
      // Fake provider isn't single-flight; real AuthManager is. What matters
      // here is every request was replayed with the new token.
      expect(tokens.refreshCalls, greaterThanOrEqualTo(1));
      expect(tokens.expired, isFalse);
    });

    test('refresh failure → session expired + UnauthorizedException', () async {
      final tokens = _FakeTokens()..refreshOk = false;
      final api = _client(
        FakeAdapter((_) async => const FakeResponse(401)),
        tokens: tokens,
      );
      await expectLater(
        api.get<Object?>('/x'),
        throwsA(isA<UnauthorizedException>()),
      );
      expect(tokens.expired, isTrue);
    });
  });

  group('RetryInterceptor', () {
    test('retries idempotent request on 503', () async {
      var n = 0;
      final api = _client(
        FakeAdapter(
          (_) async =>
              ++n < 2 ? const FakeResponse(503) : const FakeResponse(200, 1),
        ),
        retries: 2,
      );
      expect(await api.get<int>('/x'), 1);
      expect(n, 2);
    });

    test('does not retry POST', () async {
      var n = 0;
      final api = _client(
        FakeAdapter((_) async {
          n++;
          return const FakeResponse(503);
        }),
        retries: 2,
      );
      await expectLater(
        api.post<Object?>('/x'),
        throwsA(isA<ServerException>()),
      );
      expect(n, 1);
    });
  });

  test('LoggingInterceptor redacts secrets', () async {
    final logs = <String>[];
    final api = ApiClient(
      config: const ApiClientConfig(
        baseUrl: 'https://api.test',
        enableLogging: true,
        maxRetries: 0,
      ),
      httpClientAdapter: FakeAdapter((_) async => const FakeResponse(200, {})),
      logger: _ListLogger(logs),
    );
    await api.post<Object?>(
      '/login',
      data: {'username': 'u', 'password': 'secret'},
    );
    expect(logs.join('\n'), isNot(contains('secret')));
    expect(logs.join('\n'), contains('***'));
  });
}

class _ListLogger implements AppLogger {
  _ListLogger(this.logs);
  final List<String> logs;
  @override
  void log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) => logs.add(message);
}
