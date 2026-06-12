import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:inotes/features/notes/domain/entities/note_tag_entity.dart';
import 'package:inotes/features/notes/domain/errors/note_failures.dart';
import 'package:inotes/features/notes/domain/usecases/create_note_use_case.dart';
import 'package:inotes/features/notes/domain/usecases/delete_note_use_case.dart';
import 'package:inotes/features/notes/domain/usecases/update_note_use_case.dart';
import 'package:inotes/features/notes/presentation/cubit/note_detail_state.dart';
import 'package:inotes/features/tags/domain/usecases/get_tags_use_case.dart';

class NoteDetailCubit extends Cubit<NoteDetailState> {
  NoteDetailCubit(
    this._createNoteUseCase,
    this._updateNoteUseCase,
    this._deleteNoteUseCase,
    this._getSessionUseCase,
    this._getTagsUseCase,
  ) : super(const NoteDetailInitial());

  final CreateNoteUseCase _createNoteUseCase;
  final UpdateNoteUseCase _updateNoteUseCase;
  final DeleteNoteUseCase _deleteNoteUseCase;
  final GetCurrentSessionUseCase _getSessionUseCase;
  final GetTagsUseCase _getTagsUseCase;

  List<NoteTagEntity> _selectedTags = [];

  Future<void> loadTags({List<NoteTagEntity> initialTags = const []}) async {
    _selectedTags = List.of(initialTags);
    final result = await _getTagsUseCase.execute();
    switch (result) {
      case Success(:final value):
        emit(NoteDetailTagsLoaded(availableTags: value, selectedTagIds: _selectedTagIds));
      case Failure():
        emit(const NoteDetailTagsLoaded(availableTags: [], selectedTagIds: []));
    }
  }

  void toggleTag(String tagId, {required String label, required int color}) {
    final currentState = state;
    if (currentState is! NoteDetailTagsLoaded) return;

    if (_selectedTags.any((t) => t.id == tagId)) {
      _selectedTags.removeWhere((t) => t.id == tagId);
    } else if (_selectedTags.length < 3) {
      _selectedTags.add(NoteTagEntity(id: tagId, label: label, color: color));
    }

    emit(NoteDetailTagsLoaded(availableTags: currentState.availableTags, selectedTagIds: _selectedTagIds));
  }

  List<String> get _selectedTagIds => _selectedTags.map((t) => t.id).toList();

  Future<void> save({String? id, required String title, required String content}) async {
    emit(const NoteDetailSaving());

    final sessionResult = await _getSessionUseCase.execute();
    final userId = switch (sessionResult) {
      Success(:final value) => value.code,
      Failure() => null,
    };

    if (userId == null) {
      emit(const NoteDetailError('No active session.'));
      return;
    }

    final result = id == null
        ? await _createNoteUseCase.execute(userId: userId, title: title, content: content, tags: _selectedTags)
        : await _updateNoteUseCase.execute(id: id, title: title, content: content, tags: _selectedTags);

    switch (result) {
      case Success(:final value):
        emit(NoteDetailSaved(value));
      case Failure(:final failure):
        emit(NoteDetailError(failure is EmptyTitleFailure ? 'Title cannot be empty.' : 'Failed to save note.'));
    }
  }

  Future<void> delete({required String id}) async {
    emit(const NoteDetailDeleting());

    final result = await _deleteNoteUseCase.execute(id: id);

    switch (result) {
      case Success():
        emit(const NoteDetailDeleted());
      case Failure():
        emit(const NoteDetailError('Failed to delete note.'));
    }
  }
}
