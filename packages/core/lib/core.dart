/// Foundation shared by every package and app.
///
/// Has no dependency on other workspace packages and must never import
/// Flutter, Dio or any plugin.
library;

export 'src/config/app_config.dart';
export 'src/constants/storage_keys.dart';
export 'src/error/failure.dart';
export 'src/interfaces/services/cache_store.dart';
export 'src/interfaces/services/storage_service.dart';
export 'src/logger/app_logger.dart';
export 'src/models/paginated.dart';
export 'src/typedefs/json.dart';
