import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/auth/domain/usecases/clear_session_use_case.dart';
import 'package:inotes/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:inotes/features/home/presentation/cubit/home_state.dart';
import 'package:inotes/features/notes/domain/usecases/get_notes_use_case.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._getNotesUseCase, this._getSessionUseCase, this._clearSessionUseCase) : super(const HomeInitial());

  final GetNotesUseCase _getNotesUseCase;
  final GetCurrentSessionUseCase _getSessionUseCase;
  final ClearSessionUseCase _clearSessionUseCase;

  String? _sessionCode;
  String? get sessionCode => _sessionCode;

  Future<void> loadNotes() async {
    emit(const HomeLoading());

    final sessionResult = await _getSessionUseCase.execute();
    final userId = switch (sessionResult) {
      Success(:final value) => value.code,
      Failure() => null,
    };

    if (userId == null) {
      emit(const HomeError());
      return;
    }

    _sessionCode = userId;

    final result = await _getNotesUseCase.execute(userId: userId);
    switch (result) {
      case Success(:final value):
        emit(HomeLoaded(value, userId));
      case Failure():
        emit(const HomeError());
    }
  }

  Future<void> logout() async {
    _sessionCode = null;
    await _clearSessionUseCase.execute();
    emit(const HomeLoggedOut());
  }
}
