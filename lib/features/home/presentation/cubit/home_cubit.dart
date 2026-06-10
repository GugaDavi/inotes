import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/home/presentation/cubit/home_state.dart';
import 'package:inotes/features/notes/domain/usecases/get_notes_use_case.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._getNotesUseCase) : super(const HomeInitial());

  final GetNotesUseCase _getNotesUseCase;

  Future<void> loadNotes() async {
    emit(const HomeLoading());
    final result = await _getNotesUseCase.execute();
    switch (result) {
      case Success(:final value):
        emit(HomeLoaded(value));
      case Failure():
        emit(const HomeError());
    }
  }
}
