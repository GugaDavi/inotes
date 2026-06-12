import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/domain/entities/note_tag_entity.dart';

class NoteModel extends NoteEntity {
  const NoteModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.content,
    required super.createdAt,
    super.tags,
  });

  factory NoteModel.fromMap(String id, Map<String, dynamic> data) => NoteModel(
    id: id,
    userId: data['userId'] as String,
    title: data['title'] as String,
    content: data['content'] as String,
    createdAt: data['createdAt'] as DateTime,
    tags: (data['tags'] as List<dynamic>? ?? []).map((t) {
      final m = t as Map<String, dynamic>;
      return NoteTagEntity(id: m['id'] as String, label: m['label'] as String, color: m['color'] as int);
    }).toList(),
  );

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'title': title,
    'content': content,
    'createdAt': createdAt,
    'tags': tags.map((t) => {'id': t.id, 'label': t.label, 'color': t.color}).toList(),
  };
}
