/// Data layer. Repositories combine `api_client` and `storage`, expose
/// domain models and always return `Result` – never throw.
///
/// Add a feature by creating `src/<feature>/` with its model, interface and
/// `*Impl`, then export it here.
library;

export 'src/base/base_repository.dart';
export 'src/cache/cache_policy.dart';
export 'src/cache/json_cache.dart';
export 'src/user/user_profile.dart';
export 'src/user/user_repository.dart';
