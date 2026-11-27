import 'package:fpdart/fpdart.dart';

import 'error_mapper.dart';
import 'failure.dart';

/// Mixin cho tất cả Repository implementations.
///
/// Cung cấp [safeCall] để wrap try-catch → Either<Failure, T>.
/// Repository không cần viết try-catch thủ công.
///
/// ```dart
/// class UserRepositoryImpl with RepositoryMixin implements UserRepository {
///
///   @override
///   AsyncResult<User> getProfile() => safeCall(() async {
///     final response = await apiClient.get('/users/me');
///     return User.fromJson(response.data['data']);
///   });
/// }
/// ```
mixin RepositoryMixin {
  /// Wrap async call → Either<Failure, T>.
  ///
  /// Thành công → Right(T)
  /// Thất bại → Left(Failure) — tự map exception qua [ErrorMapper]
  AsyncResult<T> safeCall<T>(Future<T> Function() call) async {
    try {
      final result = await call();
      return right(result);
    } catch (e, st) {
      return left(ErrorMapper.toFailure(e, st));
    }
  }

  /// Wrap async call với validation — check response success trước.
  ///
  /// Dùng khi cần check `response.data['success'] == true` trước khi parse data.
  ///
  /// ```dart
  /// AsyncResult<User> getProfile() => safeCallApi(() async {
  ///   final response = await apiClient.get('/users/me');
  ///   return response.data;
  /// }, fromJson: (data) => User.fromJson(data));
  /// ```
  AsyncResult<T> safeCallApi<T>(
    Future<Map<String, dynamic>> Function() call, {
    required T Function(dynamic data) fromJson,
  }) async {
    try {
      final responseData = await call();

      final success = responseData['success'] as bool? ?? false;

      if (!success) {
        return left(ErrorMapper.fromResponseData(responseData));
      }

      final data = responseData['data'];
      if (data == null) {
        return left(const UnknownFailure('Response data is null'));
      }

      return right(fromJson(data));
    } catch (e, st) {
      return left(ErrorMapper.toFailure(e, st));
    }
  }

  /// Wrap async call cho list response với pagination.
  ///
  /// ```dart
  /// AsyncResult<(List<Product>, Meta)> getProducts({int page = 1}) =>
  ///   safeCallList(() async {
  ///     final response = await apiClient.get('/products', queryParameters: {'page': page});
  ///     return response.data;
  ///   }, fromJson: (item) => Product.fromJson(item));
  /// ```
  AsyncResult<(List<T>, Map<String, dynamic>?)> safeCallList<T>(
    Future<Map<String, dynamic>> Function() call, {
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    try {
      final responseData = await call();

      final success = responseData['success'] as bool? ?? false;

      if (!success) {
        return left(ErrorMapper.fromResponseData(responseData));
      }

      final data = responseData['data'];
      if (data is! List) {
        return left(const UnknownFailure('Expected list response'));
      }

      final items = data
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
      final meta = responseData['meta'] as Map<String, dynamic>?;

      return right((items, meta));
    } catch (e, st) {
      return left(ErrorMapper.toFailure(e, st));
    }
  }

  /// Wrap async call cho void operations (delete, logout, etc.).
  ///
  /// ```dart
  /// AsyncResult<void> deleteAccount() => safeCallVoid(() async {
  ///   await apiClient.delete('/users/me');
  /// });
  /// ```
  AsyncResult<void> safeCallVoid(Future<void> Function() call) async {
    try {
      await call();
      return right(null);
    } catch (e, st) {
      return left(ErrorMapper.toFailure(e, st));
    }
  }
}
