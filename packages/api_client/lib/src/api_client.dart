import 'package:core/core.dart';
import 'package:dio/dio.dart';

import 'api_options.dart';
import 'error_mapper.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Converts a decoded response body into `T`.
typedef ResponseDecoder<T> = T Function(Object? data);

/// Static configuration for [ApiClient].
final class ApiClientConfig {
  const ApiClientConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.defaultHeaders = const {},
    this.enableLogging = false,
    this.maxRetries = 2,
  });

  factory ApiClientConfig.fromAppConfig(
    AppConfig config, {
    Map<String, String> defaultHeaders = const {},
  }) => ApiClientConfig(
    baseUrl: config.apiBaseUrl,
    connectTimeout: config.connectTimeout,
    receiveTimeout: config.receiveTimeout,
    enableLogging: config.enableNetworkLogs,
    defaultHeaders: defaultHeaders,
  );

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final Map<String, String> defaultHeaders;
  final bool enableLogging;

  /// Transient-failure retries for idempotent requests. `0` disables.
  final int maxRetries;
}

/// Single HTTP entry point for the whole app.
///
/// * Every method throws an [AppException] subtype (never a [DioException]).
/// * Auth, retry and logging are wired in a fixed, correct order.
/// * [dio] is exposed so Retrofit services can share the same pipeline:
///   `UserService(apiClient.dio)`. Wrap those calls with [guard] to get the
///   same error mapping.
final class ApiClient {
  ApiClient({
    required this.config,
    AppLogger logger = const NoopLogger(),
    this.errorMapper = const ApiErrorMapper(),
    List<Interceptor> extraInterceptors = const [],
    HttpClientAdapter? httpClientAdapter,
    AuthTokenProvider? tokenProvider,
  }) : _logger = logger,
       _extraInterceptors = extraInterceptors,
       dio = Dio(
         BaseOptions(
           baseUrl: config.baseUrl,
           connectTimeout: config.connectTimeout,
           receiveTimeout: config.receiveTimeout,
           sendTimeout: config.sendTimeout,
           headers: {
             Headers.acceptHeader: Headers.jsonContentType,
             ...config.defaultHeaders,
           },
           contentType: Headers.jsonContentType,
         ),
       ) {
    if (httpClientAdapter != null) dio.httpClientAdapter = httpClientAdapter;
    _tokenProvider = tokenProvider;
    _rebuildInterceptors();
  }

  final ApiClientConfig config;
  final ApiErrorMapper errorMapper;
  final Dio dio;
  final AppLogger _logger;
  final List<Interceptor> _extraInterceptors;
  AuthTokenProvider? _tokenProvider;

  /// Installs the auth provider after construction. Needed because the
  /// auth layer itself uses this client to log in / refresh.
  void setTokenProvider(AuthTokenProvider? provider) {
    _tokenProvider = provider;
    _rebuildInterceptors();
  }

  /// Updates a default header (e.g. `Accept-Language` after locale change).
  void setHeader(String name, String? value) => value == null
      ? dio.options.headers.remove(name)
      : dio.options.headers[name] = value;

  void _rebuildInterceptors() {
    final provider = _tokenProvider;
    dio.interceptors
      ..clear()
      ..addAll([
        // Order matters: auth decorates first, retry wraps transient errors,
        // custom interceptors next, logging last so it sees final headers.
        if (provider != null)
          AuthInterceptor(tokenProvider: provider, dio: dio),
        if (config.maxRetries > 0)
          RetryInterceptor(dio: dio, maxRetries: config.maxRetries),
        ..._extraInterceptors,
        if (config.enableLogging) LoggingInterceptor(logger: _logger),
      ]);
  }

  // ---------------------------------------------------------------- verbs --

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? query,
    ResponseDecoder<T>? decoder,
    Options? options,
    CancelToken? cancelToken,
  }) => _send(
    () => dio.get<Object?>(
      path,
      queryParameters: query,
      options: options,
      cancelToken: cancelToken,
    ),
    decoder,
  );

  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    ResponseDecoder<T>? decoder,
    Options? options,
    CancelToken? cancelToken,
  }) => _send(
    () => dio.post<Object?>(
      path,
      data: data,
      queryParameters: query,
      options: options,
      cancelToken: cancelToken,
    ),
    decoder,
  );

  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    ResponseDecoder<T>? decoder,
    Options? options,
    CancelToken? cancelToken,
  }) => _send(
    () => dio.put<Object?>(
      path,
      data: data,
      queryParameters: query,
      options: options,
      cancelToken: cancelToken,
    ),
    decoder,
  );

  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    ResponseDecoder<T>? decoder,
    Options? options,
    CancelToken? cancelToken,
  }) => _send(
    () => dio.patch<Object?>(
      path,
      data: data,
      queryParameters: query,
      options: options,
      cancelToken: cancelToken,
    ),
    decoder,
  );

  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    ResponseDecoder<T>? decoder,
    Options? options,
    CancelToken? cancelToken,
  }) => _send(
    () => dio.delete<Object?>(
      path,
      data: data,
      queryParameters: query,
      options: options,
      cancelToken: cancelToken,
    ),
    decoder,
  );

  /// Multipart upload with progress (`sent`, `total` in bytes).
  Future<T> upload<T>(
    String path, {
    required FormData data,
    ResponseDecoder<T>? decoder,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) => _send(
    () => dio.post<Object?>(
      path,
      data: data,
      options: apiOptions(contentType: Headers.multipartFormDataContentType),
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    ),
    decoder,
  );

  /// Downloads [url] to [savePath].
  Future<void> download(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) => guard(
    () => dio.download(
      url,
      savePath,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
    ),
  );

  /// Runs [body] and maps any thrown error to an [AppException].
  /// Use around Retrofit-generated calls.
  Future<T> guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } catch (e, st) {
      throw errorMapper.map(e, st);
    }
  }

  Future<T> _send<T>(
    Future<Response<Object?>> Function() request,
    ResponseDecoder<T>? decoder,
  ) async {
    final response = await guard(request);
    final data = response.data;
    try {
      return decoder != null ? decoder(data) : data as T;
    } catch (e, st) {
      _logger.e(
        'Decode failed for ${response.requestOptions.uri}',
        tag: 'http',
        error: e,
        stackTrace: st,
      );
      throw ParseException(
        'Cannot decode ${response.requestOptions.path} into $T',
        cause: e,
        stackTrace: st,
      );
    }
  }
}

/// Decoder helpers for the common response shapes.
abstract final class Decoders {
  /// Body is a JSON object → model.
  static ResponseDecoder<T> object<T>(FromJson<T> fromJson) =>
      (data) => fromJson(data! as JsonMap);

  /// Body is a JSON array → list of models.
  static ResponseDecoder<List<T>> list<T>(FromJson<T> fromJson) =>
      (data) => (data! as List<dynamic>)
          .map((e) => fromJson(e as JsonMap))
          .toList(growable: false);

  /// Body is wrapped in an envelope, e.g. `{ "data": {...} }`.
  static ResponseDecoder<T> enveloped<T>(
    ResponseDecoder<T> inner, {
    String key = 'data',
  }) =>
      (data) => inner((data! as JsonMap)[key]);

  /// Paginated envelope:
  /// `{ "data": [...], "meta": { "page": 1, "pageSize": 20, "total": 95 } }`.
  /// Adjust key names to match the backend.
  static ResponseDecoder<Paginated<T>> paginated<T>(
    FromJson<T> fromJson, {
    String itemsKey = 'data',
    String metaKey = 'meta',
    String pageKey = 'page',
    String pageSizeKey = 'pageSize',
    String totalKey = 'total',
  }) => (data) {
    final json = data! as JsonMap;
    final meta = (json[metaKey] as JsonMap?) ?? const {};
    final items = (json[itemsKey] as List<dynamic>)
        .map((e) => fromJson(e as JsonMap))
        .toList(growable: false);
    return Paginated(
      items: items,
      page: (meta[pageKey] as num?)?.toInt() ?? 1,
      pageSize: (meta[pageSizeKey] as num?)?.toInt() ?? items.length,
      total: (meta[totalKey] as num?)?.toInt(),
    );
  };

  /// Ignore the body (204 / fire-and-forget endpoints).
  static void none(Object? _) {}
}
