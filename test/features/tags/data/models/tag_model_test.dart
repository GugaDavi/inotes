import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/features/tags/data/models/tag_model.dart';
import 'package:inotes/features/tags/domain/entities/tag_entity.dart';

void main() {
  group('TagModel', () {
    test('is a TagEntity', () {
      final model = TagModel(id: '1', label: 'Work', color: 0xFF007AFF);

      expect(model, isA<TagEntity>());
    });

    test('fromMap creates model from plain dart map', () {
      final model = TagModel.fromMap('1', {'label': 'Work', 'color': 0xFF007AFF});

      expect(model.id, '1');
      expect(model.label, 'Work');
      expect(model.color, 0xFF007AFF);
    });

    test('toMap returns map without id', () {
      final model = TagModel(id: '1', label: 'Work', color: 0xFF007AFF);

      final map = model.toMap();

      expect(map.containsKey('id'), isFalse);
      expect(map['label'], 'Work');
      expect(map['color'], 0xFF007AFF);
    });
  });
}
