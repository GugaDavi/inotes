import 'package:inotes/features/notes/domain/errors/note_failures.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/domain/repositories/notes_repository.dart';

class CreateNoteUseCase {
  const CreateNoteUseCase(this._repository);

  final NotesRepository _repository;

  Future<Result<NoteEntity>> execute({required String userId, required String title, required String content}) async {
    if (title.trim().isEmpty) {
      return Failure(const EmptyTitleFailure());
    }

    return _repository.create(userId: userId, title: title, content: content);
  }
}
