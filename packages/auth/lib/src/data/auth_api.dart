import 'package:api_client/api_client.dart';
import 'package:core/core.dart';

import '../models/auth_tokens.dart';
import '../models/credentials.dart';

/// Remote data source for authentication. Implementations throw
/// [AppException]s.
abstract interface class AuthApi {
  Future<OtpChallenge> requestOtp(String phone);
  Future<AuthTokens> login(LoginCredentials credentials);
  Future<AuthTokens> refresh(String refreshToken);

  /// Revokes the refresh token server-side (best effort).
  Future<void> logout({String? refreshToken});
}

/// Endpoint paths – override per backend.
final class AuthEndpoints {
  const AuthEndpoints({
    this.requestOtp = '/auth/otp/request',
    this.loginPassword = '/auth/login',
    this.loginOtp = '/auth/otp/verify',
    this.refresh = '/auth/refresh',
    this.logout = '/auth/logout',
    this.envelopeKey,
  });

  final String requestOtp;
  final String loginPassword;
  final String loginOtp;
  final String refresh;
  final String logout;

  /// Set to `'data'` if responses are wrapped as `{ "data": {...} }`.
  final String? envelopeKey;
}

/// REST implementation on top of [ApiClient].
///
/// Every call is marked `requiresAuth: false` so the [AuthInterceptor] does
/// not try to refresh while refreshing.
final class RestAuthApi implements AuthApi {
  const RestAuthApi(this._client, {this.endpoints = const AuthEndpoints()});

  final ApiClient _client;
  final AuthEndpoints endpoints;

  static final _public = apiOptions(requiresAuth: false);

  ResponseDecoder<T> _decoder<T>(FromJson<T> fromJson) {
    final inner = Decoders.object(fromJson);
    final key = endpoints.envelopeKey;
    return key == null ? inner : Decoders.enveloped(inner, key: key);
  }

  @override
  Future<OtpChallenge> requestOtp(String phone) => _client.post(
    endpoints.requestOtp,
    data: {'phone': phone},
    options: _public,
    decoder: _decoder(OtpChallenge.fromJson),
  );

  @override
  Future<AuthTokens> login(LoginCredentials credentials) => _client.post(
    switch (credentials) {
      PasswordCredentials() => endpoints.loginPassword,
      OtpCredentials() => endpoints.loginOtp,
    },
    data: credentials.toJson(),
    options: _public,
    decoder: _decoder(AuthTokens.fromJson),
  );

  @override
  Future<AuthTokens> refresh(String refreshToken) => _client.post(
    endpoints.refresh,
    data: {'refreshToken': refreshToken},
    options: _public,
    decoder: _decoder(AuthTokens.fromJson),
  );

  @override
  Future<void> logout({String? refreshToken}) => _client.post<void>(
    endpoints.logout,
    data: {'refreshToken': ?refreshToken},
    decoder: Decoders.none,
  );
}
