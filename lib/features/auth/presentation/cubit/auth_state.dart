import 'package:equatable/equatable.dart';

sealed class AuthState extends Equatable {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  List<Object?> get props => [];
}

final class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  List<Object?> get props => [];
}

final class AuthSessionCreated extends AuthState {
  const AuthSessionCreated(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated();

  @override
  List<Object?> get props => [];
}

final class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
