import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/domain/entities/note_tag_entity.dart';

abstract interface class NotesRepository {
  Future<Result<NoteEntity>> create({
    required String userId,
    required String title,
    required String content,
    List<NoteTagEntity> tags = const [],
  });
  Future<Result<List<NoteEntity>>> getAll({required String userId});
  Future<Result<NoteEntity>> update({
    required String id,
    required String title,
    required String content,
    List<NoteTagEntity> tags = const [],
  });
  Future<Result<void>> delete({required String id});
}
