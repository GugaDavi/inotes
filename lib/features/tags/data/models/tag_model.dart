import 'package:inotes/features/tags/domain/entities/tag_entity.dart';

class TagModel extends TagEntity {
  const TagModel({required super.id, required super.label, required super.color});

  factory TagModel.fromMap(String id, Map<String, dynamic> data) =>
      TagModel(id: id, label: data['label'] as String, color: data['color'] as int);

  Map<String, dynamic> toMap() => {'label': label, 'color': color};
}
