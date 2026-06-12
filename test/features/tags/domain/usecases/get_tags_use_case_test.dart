import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/tags/domain/entities/tag_entity.dart';
import 'package:inotes/features/tags/domain/repositories/tags_repository.dart';
import 'package:inotes/features/tags/domain/usecases/get_tags_use_case.dart';

class MockTagsRepository extends Mock implements TagsRepository {}

void main() {
  late GetTagsUseCase useCase;
  late MockTagsRepository mockRepository;

  setUp(() {
    mockRepository = MockTagsRepository();
    useCase = GetTagsUseCase(mockRepository);
  });

  final tTags = [const TagEntity(id: '1', label: 'Work', color: 0xFF007AFF)];

  group('GetTagsUseCase', () {
    test('delegates to repository and returns its result', () async {
      when(() => mockRepository.getAll()).thenAnswer((_) async => Success(tTags));

      final result = await useCase.execute();

      expect(result, isA<Success<List<TagEntity>>>());
      expect((result as Success<List<TagEntity>>).value, tTags);
      verify(() => mockRepository.getAll()).called(1);
    });
  });
}
