import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/notes/domain/errors/note_failures.dart';
import 'package:inotes/features/notes/domain/usecases/create_note_use_case.dart';
import 'package:inotes/features/notes/domain/usecases/delete_note_use_case.dart';
import 'package:inotes/features/notes/domain/usecases/update_note_use_case.dart';
import 'package:inotes/features/notes/presentation/cubit/note_detail_state.dart';

class NoteDetailCubit extends Cubit<NoteDetailState> {
  NoteDetailCubit(this._createNoteUseCase, this._updateNoteUseCase, this._deleteNoteUseCase)
    : super(const NoteDetailInitial());

  final CreateNoteUseCase _createNoteUseCase;
  final UpdateNoteUseCase _updateNoteUseCase;
  final DeleteNoteUseCase _deleteNoteUseCase;

  Future<void> save({String? id, required String title, required String content}) async {
    emit(const NoteDetailSaving());

    final result = id == null
        ? await _createNoteUseCase.execute(title: title, content: content)
        : await _updateNoteUseCase.execute(id: id, title: title, content: content);

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
