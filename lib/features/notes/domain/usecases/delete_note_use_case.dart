import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/notes/domain/repositories/notes_repository.dart';

class DeleteNoteUseCase {
  const DeleteNoteUseCase(this._repository);

  final NotesRepository _repository;

  Future<Result<void>> execute({required String id}) async {
    return _repository.delete(id: id);
  }
}
