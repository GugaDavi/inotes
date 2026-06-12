import 'package:inotes/core/result/result.dart';
import 'package:inotes/core/ui/app_colors.dart';
import 'package:inotes/features/tags/data/models/tag_model.dart';
import 'package:inotes/features/tags/domain/entities/tag_entity.dart';
import 'package:inotes/features/tags/domain/errors/tag_failures.dart';
import 'package:inotes/features/tags/domain/repositories/tags_repository.dart';
import 'package:inotes/services/firestore/exceptions/firestore_exceptions.dart';
import 'package:inotes/services/firestore/firestore_service.dart';

class TagsRepositoryImpl implements TagsRepository {
  TagsRepositoryImpl(this._service);

  final FirestoreService _service;

  static const _collection = 'tags';

  List<TagEntity>? _cache;

  static const _defaults = [
    (label: 'Work', color: AppColors.tagWork),
    (label: 'Personal', color: AppColors.tagPersonal),
    (label: 'Ideas', color: AppColors.tagIdeas),
    (label: 'Study', color: AppColors.tagStudy),
    (label: 'Health', color: AppColors.tagHealth),
    (label: 'Finance', color: AppColors.tagFinance),
    (label: 'Important', color: AppColors.tagImportant),
  ];

  static int get defaultTagsCount => _defaults.length;

  @override
  Future<Result<List<TagEntity>>> getAll() async {
    if (_cache != null) return Success(List.unmodifiable(_cache!));

    try {
      final docs = await _service.getAll(collection: _collection);
      final tags = docs.isEmpty
          ? await _seed()
          : docs.map((doc) => TagModel.fromMap(doc.id, doc.data) as TagEntity).toList();
      _cache = tags;
      return Success(List.unmodifiable(tags));
    } on FirestoreOperationException catch (e) {
      return Failure(TagFirestoreFailure(e.message));
    }
  }

  Future<List<TagEntity>> _seed() async {
    final seeded = <TagEntity>[];
    for (final tag in _defaults) {
      final doc = await _service.add(
        collection: _collection,
        data: {'label': tag.label, 'color': tag.color.toARGB32()},
      );
      seeded.add(TagModel.fromMap(doc.id, doc.data));
    }
    return seeded;
  }
}
