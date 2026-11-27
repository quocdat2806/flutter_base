import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_bloc.freezed.dart';

@freezed
sealed class AuthEvent with _$AuthEvent {
  /// Starts following [AuthManager.status]. Added by the bloc itself.
  const factory AuthEvent.started() = AuthStarted;
  const factory AuthEvent.loginRequested(LoginCredentials credentials) =
      AuthLoginRequested;
  const factory AuthEvent.logoutRequested() = AuthLogoutRequested;
}

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    /// Session state, mirrored from [AuthManager].
    @Default(AuthUnknown()) AuthStatus status,

    /// A login / logout request is in flight.
    @Default(false) bool isSubmitting,

    /// Why the last login failed; cleared on the next attempt.
    AppException? error,
  }) = _AuthState;

  const AuthState._();

  bool get isAuthenticated => status is Authenticated;
}

/// App-wide session bloc on top of [AuthManager].
///
/// [AuthManager] stays the single source of truth (it also reacts to 401s
/// and failed refreshes); this bloc mirrors its status for the UI / router
/// and runs login and logout.
final class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._auth) : super(AuthState(status: _auth.currentStatus)) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    add(const AuthEvent.started());
  }

  final AuthManager _auth;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) =>
      emit.forEach(
        _auth.status,
        onData: (status) => state.copyWith(status: status),
      );

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true, error: null));
    final result = await _auth.login(event.credentials);
    // On success the new status arrives through the status stream.
    emit(state.copyWith(isSubmitting: false, error: result.errorOrNull));
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true, error: null));
    await _auth.logout();
    emit(state.copyWith(isSubmitting: false));
  }
}
