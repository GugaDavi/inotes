import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/notes/domain/errors/note_failures.dart';
import 'package:inotes/features/notes/domain/usecases/create_note.dart';
import 'package:inotes/features/notes/domain/usecases/update_note.dart';
import 'package:inotes/features/notes/presentation/cubit/note_detail_state.dart';

class NoteDetailCubit extends Cubit<NoteDetailState> {
  NoteDetailCubit(this._createNote, this._updateNote)
      : super(const NoteDetailInitial());

  final CreateNote _createNote;
  final UpdateNote _updateNote;

  Future<void> save({
    String? id,
    required String title,
    required String content,
  }) async {
    emit(const NoteDetailSaving());

    final result = id == null
        ? await _createNote.execute(title: title, content: content)
        : await _updateNote.execute(id: id, title: title, content: content);

    switch (result) {
      case Success(:final value):
        emit(NoteDetailSaved(value));
      case Failure(:final failure):
        emit(NoteDetailError(
          failure is EmptyTitleFailure
              ? 'Title cannot be empty.'
              : 'Failed to save note.',
        ));
    }
  }
}
