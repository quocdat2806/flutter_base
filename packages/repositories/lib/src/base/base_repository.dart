import 'dart:async';

import 'package:core/core.dart';

/// Common plumbing for repository implementations: converts thrown
/// [AppException]s into [Result]s and logs unexpected errors once.
abstract base class BaseRepository {
  const BaseRepository({this.logger = const NoopLogger()});

  final AppLogger logger;

  /// Executes [body] and wraps the outcome in a [Result].
  Future<Result<T>> guard<T>(FutureOr<T> Function() body) async {
    try {
      return Success(await body());
    } on AppException catch (e) {
      return Failure(e);
    } catch (e, st) {
      // Non-AppException means a bug (bad cast, null check…) – surface it.
      logger.e(
        'Unexpected error in $runtimeType',
        tag: 'repo',
        error: e,
        stackTrace: st,
      );
      return Failure(UnknownException.from(e, st));
    }
  }
}
