import 'package:equatable/equatable.dart';
import 'package:inotes/features/notes/domain/entities/note_tag_entity.dart';

class NoteEntity extends Equatable {
  const NoteEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
  });

  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<NoteTagEntity> tags;

  @override
  List<Object?> get props => [id, userId, title, content, createdAt, updatedAt, tags];
}
