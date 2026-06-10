import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/home/presentation/cubit/home_state.dart';
import 'package:inotes/features/notes/domain/usecases/get_notes.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._getNotes) : super(const HomeInitial());

  final GetNotes _getNotes;

  Future<void> loadNotes() async {
    emit(const HomeLoading());
    final result = await _getNotes.execute();
    switch (result) {
      case Success(:final value):
        emit(HomeLoaded(value));
      case Failure():
        emit(const HomeError());
    }
  }
}
