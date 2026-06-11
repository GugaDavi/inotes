import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/domain/repositories/notes_repository.dart';

class GetNoteByIdUseCase {
  const GetNoteByIdUseCase(this._repository);

  final NotesRepository _repository;

  Future<Result<NoteEntity>> execute({required String id}) => _repository.getById(id: id);
}
