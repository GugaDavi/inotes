import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/auth/domain/usecases/clear_session_use_case.dart';
import 'package:inotes/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:inotes/features/home/domain/entities/filter_options_entity.dart';
import 'package:inotes/features/home/presentation/cubits/home_cubit/home_state.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/domain/usecases/get_notes_use_case.dart';
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

  FilterOptionsEntity? _currentOptions;
  String _currentQuery = '';
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
        final filtered = _applyFilters(value);
        emit(HomeLoaded(notes: value, filteredNotes: filtered, sessionCode: userId));
      case Failure():
        emit(const HomeError());
    }
  }

  void handleFilterChange(FilterOptionsEntity? options) {
    _currentOptions = options;
    final current = state;
    if (current is! HomeLoaded || isClosed) return;
    _searcher.search(current.notes, _currentQuery);
  }

  void applyFilter(String query) {
    _currentQuery = query;
    final current = state;
    if (current is! HomeLoaded || isClosed) return;
    _searcher.search(current.notes, query);
  }

  void _onSearchResult(List<NoteEntity> textFiltered, String query) {
    final current = state;
    if (current is! HomeLoaded || isClosed) return;
    final filtered = _applyFilters(textFiltered);
    emit(
      HomeLoaded(
        notes: current.notes,
        filteredNotes: filtered,
        sessionCode: current.sessionCode,
        textFiltered: query.isEmpty ? null : query,
      ),
    );
  }

  List<NoteEntity> _applyFilters(List<NoteEntity> notes) {
    var result = notes;
    if (_currentOptions?.dateFilter != null) {
      result = result.where((n) => _currentOptions!.dateFilter!.matches(n.createdAt)).toList();
    }
    if (_currentOptions?.tagFilter.isNotEmpty == true) {
      result = result.where((n) => n.tags.any((t) => _currentOptions!.tagFilter.contains(t.id))).toList();
    }
    return result;
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
