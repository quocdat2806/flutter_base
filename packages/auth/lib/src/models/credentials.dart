import 'package:core/core.dart';

/// Supported sign-in methods.
sealed class LoginCredentials {
  const LoginCredentials();

  JsonMap toJson();
}

/// Username (phone/email) + password.
final class PasswordCredentials extends LoginCredentials {
  const PasswordCredentials({required this.username, required this.password});

  final String username;
  final String password;

  @override
  JsonMap toJson() => {'username': username, 'password': password};
}

/// Phone + one-time password received by SMS / Zalo.
final class OtpCredentials extends LoginCredentials {
  const OtpCredentials({
    required this.phone,
    required this.otp,
    this.requestId,
  });

  /// E.164 phone number.
  final String phone;
  final String otp;

  /// Id returned by `requestOtp`, if the backend needs it.
  final String? requestId;

  @override
  JsonMap toJson() => {
    'phone': phone,
    'otp': otp,
    if (requestId != null) 'requestId': requestId,
  };
}

/// Response of an OTP request.
final class OtpChallenge {
  const OtpChallenge({this.requestId, this.resendAfter, this.expiresIn});

  factory OtpChallenge.fromJson(JsonMap json) => OtpChallenge(
    requestId: (json['requestId'] ?? json['request_id'])?.toString(),
    resendAfter: _seconds(json['resendAfter'] ?? json['resend_after']),
    expiresIn: _seconds(json['expiresIn'] ?? json['expires_in']),
  );

  final String? requestId;

  /// Cooldown before the user may request another code.
  final Duration? resendAfter;
  final Duration? expiresIn;

  static Duration? _seconds(Object? v) =>
      v is num ? Duration(seconds: v.toInt()) : null;
}
