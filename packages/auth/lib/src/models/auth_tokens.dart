import 'package:core/core.dart';

/// Access/refresh token pair issued by the backend.
final class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.tokenType = 'Bearer',
  });

  /// Accepts both camelCase and snake_case keys, and either an absolute
  /// `expiresAt` (ISO-8601) or a relative `expiresIn` (seconds).
  factory AuthTokens.fromJson(JsonMap json, {DateTime? now}) {
    final access = json['accessToken'] ?? json['access_token'];
    if (access is! String || access.isEmpty) {
      throw const ParseException('Missing access token');
    }
    final expiresAtRaw = json['expiresAt'] ?? json['expires_at'];
    final expiresIn = json['expiresIn'] ?? json['expires_in'];
    return AuthTokens(
      accessToken: access,
      refreshToken: (json['refreshToken'] ?? json['refresh_token']) as String?,
      tokenType:
          (json['tokenType'] ?? json['token_type']) as String? ?? 'Bearer',
      expiresAt: switch ((expiresAtRaw, expiresIn)) {
        (final String iso, _) => DateTime.tryParse(iso)?.toUtc(),
        (_, final num seconds) => (now ?? DateTime.now()).toUtc().add(
          Duration(seconds: seconds.toInt()),
        ),
        _ => null,
      },
    );
  }

  final String accessToken;
  final String? refreshToken;

  /// UTC expiry of [accessToken], when known.
  final DateTime? expiresAt;
  final String tokenType;

  bool get canRefresh => refreshToken != null && refreshToken!.isNotEmpty;

  /// `true` if the token expires within [leeway] from [now].
  bool isExpired({
    Duration leeway = const Duration(seconds: 30),
    DateTime? now,
  }) {
    final exp = expiresAt;
    if (exp == null) return false;
    return !(now ?? DateTime.now()).toUtc().add(leeway).isBefore(exp);
  }

  JsonMap toJson() => {
    'accessToken': accessToken,
    if (refreshToken != null) 'refreshToken': refreshToken,
    if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
    'tokenType': tokenType,
  };

  /// Keeps the old refresh token when the server rotates only the access
  /// token.
  AuthTokens mergeWith(AuthTokens fresh) => AuthTokens(
    accessToken: fresh.accessToken,
    refreshToken: fresh.refreshToken ?? refreshToken,
    expiresAt: fresh.expiresAt,
    tokenType: fresh.tokenType,
  );

  @override
  bool operator ==(Object other) =>
      other is AuthTokens &&
      other.accessToken == accessToken &&
      other.refreshToken == refreshToken &&
      other.expiresAt == expiresAt;

  @override
  int get hashCode => Object.hash(accessToken, refreshToken, expiresAt);

  @override
  String toString() =>
      'AuthTokens(expiresAt: $expiresAt, '
      'canRefresh: $canRefresh)'; // never print token values
}
