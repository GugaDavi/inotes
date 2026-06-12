import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/features/notes/data/models/note_model.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/domain/entities/note_tag_entity.dart';

void main() {
  final tCreatedAt = DateTime(2026, 6, 10);

  group('NoteModel', () {
    test('is a NoteEntity', () {
      final model = NoteModel(id: '1', userId: 'user-a', title: 'Title', content: 'Content', createdAt: tCreatedAt);

      expect(model, isA<NoteEntity>());
    });

    test('fromMap creates model from plain dart map without tags', () {
      final model = NoteModel.fromMap('1', {
        'userId': 'user-a',
        'title': 'Title',
        'content': 'Content',
        'createdAt': tCreatedAt,
      });

      expect(model.id, '1');
      expect(model.userId, 'user-a');
      expect(model.title, 'Title');
      expect(model.content, 'Content');
      expect(model.createdAt, tCreatedAt);
      expect(model.tags, isEmpty);
    });

    test('fromMap deserializes tags list', () {
      final model = NoteModel.fromMap('1', {
        'userId': 'user-a',
        'title': 'Title',
        'content': 'Content',
        'createdAt': tCreatedAt,
        'tags': [
          {'id': 'tag1', 'label': 'Work', 'color': 0xFF007AFF},
        ],
      });

      expect(model.tags, [const NoteTagEntity(id: 'tag1', label: 'Work', color: 0xFF007AFF)]);
    });

    test('toMap returns map without id and includes tags', () {
      final model = NoteModel(
        id: '1',
        userId: 'user-a',
        title: 'Title',
        content: 'Content',
        createdAt: tCreatedAt,
        tags: const [NoteTagEntity(id: 'tag1', label: 'Work', color: 0xFF007AFF)],
      );

      final map = model.toMap();

      expect(map.containsKey('id'), isFalse);
      expect(map['userId'], 'user-a');
      expect(map['title'], 'Title');
      expect(map['content'], 'Content');
      expect(map['createdAt'], tCreatedAt);
      expect(map['tags'], [
        {'id': 'tag1', 'label': 'Work', 'color': 0xFF007AFF},
      ]);
    });

    test('toMap includes empty tags list when note has no tags', () {
      final model = NoteModel(id: '1', userId: 'user-a', title: 'Title', content: 'Content', createdAt: tCreatedAt);

      final map = model.toMap();

      expect(map['tags'], isEmpty);
    });
  });
}
