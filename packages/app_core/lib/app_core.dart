/// Flutter-side foundation shared by every app.
///
/// `core` stays pure Dart; anything that needs Flutter or flutter_bloc and is
/// common to all apps (bootstrap, dependency wiring, shared blocs) lives here.
library;

export 'src/blocs/auth/auth_bloc.dart';
export 'src/blocs/theme/theme_mode_cubit.dart';
export 'src/bootstrap/app_bloc_observer.dart';
export 'src/bootstrap/app_bootstrap.dart';
export 'src/bootstrap/app_dependencies.dart';
export 'src/cache/app_network_image.dart';
export 'src/cache/dio_file_service.dart';
export 'src/cache/file_cache_service.dart';
export 'src/cache/session_cache_guard.dart';
