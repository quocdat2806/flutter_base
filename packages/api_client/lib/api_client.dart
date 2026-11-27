/// HTTP layer: one configured [ApiClient] (Dio) with auth refresh, retry,
/// logging and mapping of every failure to `core`'s `AppException`.
library;

export 'package:dio/dio.dart'
    show CancelToken, FormData, MultipartFile, Options, ProgressCallback;

export 'src/api_client.dart';
export 'src/api_options.dart';
export 'src/error_mapper.dart';
export 'src/interceptors/auth_interceptor.dart';
export 'src/interceptors/logging_interceptor.dart';
export 'src/interceptors/retry_interceptor.dart';
