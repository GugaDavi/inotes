import 'package:inotes/features/notes/domain/entities/note_entity.dart';

class NoteModel extends NoteEntity {
  const NoteModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.content,
    required super.createdAt,
  });

  factory NoteModel.fromMap(String id, Map<String, dynamic> data) => NoteModel(
    id: id,
    userId: data['userId'] as String,
    title: data['title'] as String,
    content: data['content'] as String,
    createdAt: data['createdAt'] as DateTime,
  );

  Map<String, dynamic> toMap() => {'userId': userId, 'title': title, 'content': content, 'createdAt': createdAt};
}
