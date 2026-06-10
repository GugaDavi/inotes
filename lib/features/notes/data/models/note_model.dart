import 'package:inotes/features/notes/domain/entities/note_entity.dart';

class NoteModel extends NoteEntity {
  const NoteModel({required super.id, required super.title, required super.content, required super.createdAt});

  factory NoteModel.fromMap(String id, Map<String, dynamic> data) => NoteModel(
    id: id,
    title: data['title'] as String,
    content: data['content'] as String,
    createdAt: data['createdAt'] as DateTime,
  );

  Map<String, dynamic> toMap() => {'title': title, 'content': content, 'createdAt': createdAt};
}
