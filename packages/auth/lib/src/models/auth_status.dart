/// Why the user is not signed in.
enum SignedOutReason {
  /// Fresh install or tokens never stored.
  initial,

  /// User tapped "log out".
  userInitiated,

  /// Refresh token rejected – show "session expired" and route to login.
  sessionExpired,
}

/// Authentication state machine exposed to the UI / router.
sealed class AuthStatus {
  const AuthStatus();
}

/// Session not restored yet (splash screen).
final class AuthUnknown extends AuthStatus {
  const AuthUnknown();

  @override
  String toString() => 'AuthUnknown';
}

final class Authenticated extends AuthStatus {
  const Authenticated();

  @override
  bool operator ==(Object other) => other is Authenticated;

  @override
  int get hashCode => (Authenticated).hashCode;

  @override
  String toString() => 'Authenticated';
}

final class Unauthenticated extends AuthStatus {
  const Unauthenticated([this.reason = SignedOutReason.initial]);

  final SignedOutReason reason;

  @override
  bool operator ==(Object other) =>
      other is Unauthenticated && other.reason == reason;

  @override
  int get hashCode => reason.hashCode;

  @override
  String toString() => 'Unauthenticated(${reason.name})';
}
