import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/features/notes/data/models/note_model.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';

void main() {
  final tCreatedAt = DateTime(2026, 6, 10);

  group('NoteModel', () {
    test('is a NoteEntity', () {
      final model = NoteModel(id: '1', userId: 'user-a', title: 'Title', content: 'Content', createdAt: tCreatedAt);

      expect(model, isA<NoteEntity>());
    });

    test('fromMap creates model from plain dart map', () {
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
    });

    test('toMap returns map without id', () {
      final model = NoteModel(id: '1', userId: 'user-a', title: 'Title', content: 'Content', createdAt: tCreatedAt);

      final map = model.toMap();

      expect(map.containsKey('id'), isFalse);
      expect(map['userId'], 'user-a');
      expect(map['title'], 'Title');
      expect(map['content'], 'Content');
      expect(map['createdAt'], tCreatedAt);
    });
  });
}
