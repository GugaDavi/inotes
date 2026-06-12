import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/domain/entities/note_tag_entity.dart';
import 'package:inotes/features/notes/domain/errors/note_failures.dart';
import 'package:inotes/features/notes/domain/repositories/notes_repository.dart';

class UpdateNoteUseCase {
  const UpdateNoteUseCase(this._repository);

  final NotesRepository _repository;

  Future<Result<NoteEntity>> execute({
    required String id,
    required String title,
    required String content,
    List<NoteTagEntity> tags = const [],
  }) async {
    if (title.trim().isEmpty) {
      return Failure(const EmptyTitleFailure());
    }

    return _repository.update(id: id, title: title, content: content, tags: tags);
  }
}
