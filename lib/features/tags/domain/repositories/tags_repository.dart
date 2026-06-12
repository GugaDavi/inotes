import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/tags/domain/entities/tag_entity.dart';

abstract interface class TagsRepository {
  Future<Result<List<TagEntity>>> getAll();
}
