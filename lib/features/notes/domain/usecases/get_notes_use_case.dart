import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/domain/repositories/notes_repository.dart';

class GetNotesUseCase {
  const GetNotesUseCase(this._repository);

  final NotesRepository _repository;

  Future<Result<List<NoteEntity>>> execute() async {
    return _repository.getAll();
  }
}
