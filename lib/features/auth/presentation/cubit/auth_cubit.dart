import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:inotes/features/auth/domain/usecases/start_session_use_case.dart';
import 'package:inotes/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._getSessionUseCase, this._startSessionUseCase) : super(const AuthInitial());

  final GetCurrentSessionUseCase _getSessionUseCase;
  final StartSessionUseCase _startSessionUseCase;

  Future<void> checkSession() async {
    final result = await _getSessionUseCase.execute();
    switch (result) {
      case Success():
        emit(const AuthAuthenticated());
      case Failure():
        emit(const AuthInitial());
    }
  }

  Future<void> enterCode(String code) async {
    if (code.trim().isEmpty) {
      emit(const AuthError('Please enter a session code.'));
      return;
    }
    emit(const AuthLoading());
    final result = await _startSessionUseCase.execute(code: code.trim().toUpperCase());
    switch (result) {
      case Success():
        emit(const AuthAuthenticated());
      case Failure():
        emit(const AuthError('Failed to start session.'));
    }
  }

  Future<void> startNewSession() async {
    emit(const AuthLoading());
    final result = await _startSessionUseCase.execute();
    switch (result) {
      case Success(:final value):
        emit(AuthSessionCreated(value.code));
      case Failure():
        emit(const AuthError('Failed to create session.'));
    }
  }

  void confirmNewSession() => emit(const AuthAuthenticated());
}
