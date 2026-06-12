import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/tags/data/models/tag_model.dart';
import 'package:inotes/features/tags/data/repositories/tags_repository_impl.dart';
import 'package:inotes/features/tags/domain/entities/tag_entity.dart';
import 'package:inotes/features/tags/domain/errors/tag_failures.dart';
import 'package:inotes/services/firestore/exceptions/firestore_exceptions.dart';
import 'package:inotes/services/firestore/firestore_service.dart';

class MockFirestoreService extends Mock implements FirestoreService {}

void main() {
  late TagsRepositoryImpl repository;
  late MockFirestoreService mockService;

  setUp(() {
    mockService = MockFirestoreService();
    repository = TagsRepositoryImpl(mockService);
  });

  const tTagDoc = (id: '1', data: {'label': 'Work', 'color': 0xFF007AFF});
  const tTag = TagModel(id: '1', label: 'Work', color: 0xFF007AFF);

  group('getAll', () {
    test('returns Success(List<TagEntity>) when tags already exist', () async {
      when(() => mockService.getAll(collection: any(named: 'collection'))).thenAnswer((_) async => [tTagDoc]);

      final result = await repository.getAll();

      expect(result, isA<Success<List<TagEntity>>>());
      expect((result as Success<List<TagEntity>>).value, [tTag]);
    });

    test('returns cached result without hitting Firestore on second call', () async {
      when(() => mockService.getAll(collection: any(named: 'collection'))).thenAnswer((_) async => [tTagDoc]);

      await repository.getAll();
      await repository.getAll();

      verify(() => mockService.getAll(collection: any(named: 'collection'))).called(1);
    });

    test('seeds default tags and returns them when collection is empty', () async {
      when(
        () => mockService.getAll(collection: any(named: 'collection')),
      ).thenAnswer((_) async => []);
      when(
        () => mockService.add(collection: any(named: 'collection'), data: any(named: 'data')),
      ).thenAnswer((inv) async {
        final data = inv.namedArguments[const Symbol('data')] as Map<String, dynamic>;
        return (id: 'seeded', data: data);
      });

      final result = await repository.getAll();

      expect(result, isA<Success<List<TagEntity>>>());
      final tags = (result as Success<List<TagEntity>>).value;
      expect(tags, isNotEmpty);
      verify(() => mockService.add(collection: any(named: 'collection'), data: any(named: 'data'))).called(
        TagsRepositoryImpl.defaultTagsCount,
      );
    });

    test('returns Failure(TagFirestoreFailure) on FirestoreOperationException during getAll', () async {
      when(
        () => mockService.getAll(collection: any(named: 'collection')),
      ).thenThrow(const FirestoreOperationException());

      final result = await repository.getAll();

      expect(result, isA<Failure<List<TagEntity>>>());
      expect((result as Failure<List<TagEntity>>).failure, isA<TagFirestoreFailure>());
    });

    test('returns Failure(TagFirestoreFailure) on FirestoreOperationException during seed', () async {
      when(
        () => mockService.getAll(collection: any(named: 'collection')),
      ).thenAnswer((_) async => []);
      when(
        () => mockService.add(collection: any(named: 'collection'), data: any(named: 'data')),
      ).thenThrow(const FirestoreOperationException());

      final result = await repository.getAll();

      expect(result, isA<Failure<List<TagEntity>>>());
      expect((result as Failure<List<TagEntity>>).failure, isA<TagFirestoreFailure>());
    });
  });
}
