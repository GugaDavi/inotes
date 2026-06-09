import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';

abstract interface class NotesRepository {
  Future<Result<NoteEntity>> create({required String title, required String content});
}
