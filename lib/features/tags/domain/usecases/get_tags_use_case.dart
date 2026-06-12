import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/tags/domain/entities/tag_entity.dart';
import 'package:inotes/features/tags/domain/repositories/tags_repository.dart';

class GetTagsUseCase {
  const GetTagsUseCase(this._repository);

  final TagsRepository _repository;

  Future<Result<List<TagEntity>>> execute() => _repository.getAll();
}
