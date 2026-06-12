import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/auth/domain/usecases/clear_session_use_case.dart';
import 'package:inotes/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:inotes/features/home/presentation/cubit/home_state.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/domain/usecases/get_notes_use_case.dart';
import 'package:inotes/features/shared/filter/date_range_filter.dart';
import 'package:inotes/features/shared/search/note_searcher.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._getNotesUseCase, this._getSessionUseCase, this._clearSessionUseCase) : super(const HomeInitial()) {
    _searcher = NoteSearcher(onResult: _onSearchResult);
  }

  final GetNotesUseCase _getNotesUseCase;
  final GetCurrentSessionUseCase _getSessionUseCase;
  final ClearSessionUseCase _clearSessionUseCase;

  String? _sessionCode;
  String? get sessionCode => _sessionCode;

  DateRangeFilter? _dateFilter;
  late final NoteSearcher _searcher;

  Future<void> loadNotes() async {
    _searcher.dispose();
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
        final filtered = _applyDateFilter(value);
        emit(HomeLoaded(notes: value, filteredNotes: filtered, sessionCode: userId, dateFilter: _dateFilter));
      case Failure():
        emit(const HomeError());
    }
  }

  void _onSearchResult(List<NoteEntity> textFiltered, String query) {
    final current = state;
    if (current is! HomeLoaded || isClosed) return;
    final filtered = _applyDateFilter(textFiltered);
    emit(
      HomeLoaded(
        notes: current.notes,
        filteredNotes: filtered,
        sessionCode: current.sessionCode,
        query: query,
        dateFilter: _dateFilter,
      ),
    );
  }

  void search(String query) {
    final current = state;
    if (current is! HomeLoaded) return;
    _searcher.search(current.notes, query);
  }

  void applyDateFilter(DateRangeFilter? filter) {
    final current = state;
    if (current is! HomeLoaded) return;
    _dateFilter = filter;
    _searcher.search(current.notes, current.query);
  }

  List<NoteEntity> _applyDateFilter(List<NoteEntity> notes) {
    if (_dateFilter == null) return notes;
    return notes.where((n) => _dateFilter!.matches(n.createdAt)).toList();
  }

  Future<void> logout() async {
    _sessionCode = null;
    await _clearSessionUseCase.execute();
    emit(const HomeLoggedOut());
  }

  @override
  Future<void> close() {
    _searcher.dispose();
    return super.close();
  }
}
