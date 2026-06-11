import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:inotes/features/notes/domain/errors/note_failures.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
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

  group('CreateNoteUseCase', () {
    final tNote = NoteEntity(
      id: '1',
      userId: 'user-a',
      title: 'Test Title',
      content: 'Test content',
      createdAt: DateTime(2026, 6, 9),
    );

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
        ),
      ).thenAnswer((_) async => Success(tNote));

      final result = await useCase.execute(userId: 'user-a', title: 'Test Title', content: 'Test content');

      expect(result, isA<Success<NoteEntity>>());
      expect((result as Success<NoteEntity>).value, tNote);
      verify(() => mockRepository.create(userId: 'user-a', title: 'Test Title', content: 'Test content')).called(1);
    });
  });
}
