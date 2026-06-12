import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:inotes/features/notes/domain/errors/note_failures.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/domain/entities/note_tag_entity.dart';
import 'package:inotes/features/notes/domain/repositories/notes_repository.dart';
import 'package:inotes/features/notes/domain/usecases/create_note_use_case.dart';

class MockNotesRepository extends Mock implements NotesRepository {}

void main() {
  late CreateNoteUseCase useCase;
  late MockNotesRepository mockRepository;

  setUp(() {
    mockRepository = MockNotesRepository();
    useCase = CreateNoteUseCase(mockRepository);
  });

  final tNote = NoteEntity(
    id: '1',
    userId: 'user-a',
    title: 'Test Title',
    content: 'Test content',
    createdAt: DateTime(2026, 6, 9),
  );

  group('CreateNoteUseCase', () {
    test('should return Failure(EmptyTitleFailure) when title is empty', () async {
      final result = await useCase.execute(userId: 'user-a', title: '', content: 'Test content');

      expect(result, isA<Failure<NoteEntity>>());
      expect((result as Failure<NoteEntity>).failure, isA<EmptyTitleFailure>());
      verifyNever(
        () => mockRepository.create(
          userId: any(named: 'userId'),
          title: any(named: 'title'),
          content: any(named: 'content'),
        ),
      );
    });

    test('should return Failure(EmptyTitleFailure) when title is whitespace only', () async {
      final result = await useCase.execute(userId: 'user-a', title: '   ', content: 'Test content');

      expect(result, isA<Failure<NoteEntity>>());
      expect((result as Failure<NoteEntity>).failure, isA<EmptyTitleFailure>());
      verifyNever(
        () => mockRepository.create(
          userId: any(named: 'userId'),
          title: any(named: 'title'),
          content: any(named: 'content'),
        ),
      );
    });

    test('should call repository and return Success(NoteEntity) when title is valid', () async {
      when(
        () => mockRepository.create(
          userId: any(named: 'userId'),
          title: any(named: 'title'),
          content: any(named: 'content'),
          tags: any(named: 'tags'),
        ),
      ).thenAnswer((_) async => Success(tNote));

      final result = await useCase.execute(userId: 'user-a', title: 'Test Title', content: 'Test content');

      expect(result, isA<Success<NoteEntity>>());
      expect((result as Success<NoteEntity>).value, tNote);
      verify(
        () => mockRepository.create(userId: 'user-a', title: 'Test Title', content: 'Test content', tags: []),
      ).called(1);
    });

    test('forwards tags to repository', () async {
      const tTag = NoteTagEntity(id: 'tag1', label: 'Work', color: 0xFF007AFF);
      when(
        () => mockRepository.create(
          userId: any(named: 'userId'),
          title: any(named: 'title'),
          content: any(named: 'content'),
          tags: any(named: 'tags'),
        ),
      ).thenAnswer((_) async => Success(tNote));

      await useCase.execute(userId: 'user-a', title: 'Test Title', content: 'Content', tags: [tTag]);

      verify(
        () => mockRepository.create(userId: 'user-a', title: 'Test Title', content: 'Content', tags: [tTag]),
      ).called(1);
    });
  });
}
