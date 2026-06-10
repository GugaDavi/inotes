import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/domain/errors/note_failures.dart';
import 'package:inotes/features/notes/domain/repositories/notes_repository.dart';
import 'package:inotes/features/notes/domain/usecases/update_note.dart';

class MockNotesRepository extends Mock implements NotesRepository {}

void main() {
  late UpdateNote useCase;
  late MockNotesRepository mockRepository;

  setUp(() {
    mockRepository = MockNotesRepository();
    useCase = UpdateNote(mockRepository);
  });

  group('UpdateNote', () {
    const tId = '1';
    final tNote = NoteEntity(
      id: tId,
      title: 'Updated Title',
      content: 'Updated content',
      createdAt: DateTime(2026, 6, 9),
    );

    test('should return Failure(EmptyTitleFailure) when title is empty', () async {
      final result = await useCase.execute(id: tId, title: '', content: 'Updated content');

      expect(result, isA<Failure<NoteEntity>>());
      expect((result as Failure<NoteEntity>).failure, isA<EmptyTitleFailure>());
      verifyNever(() => mockRepository.update(id: any(named: 'id'), title: any(named: 'title'), content: any(named: 'content')));
    });

    test('should return Failure(EmptyTitleFailure) when title is whitespace only', () async {
      final result = await useCase.execute(id: tId, title: '   ', content: 'Updated content');

      expect(result, isA<Failure<NoteEntity>>());
      expect((result as Failure<NoteEntity>).failure, isA<EmptyTitleFailure>());
      verifyNever(() => mockRepository.update(id: any(named: 'id'), title: any(named: 'title'), content: any(named: 'content')));
    });

    test('should call repository and return Success(NoteEntity) when title is valid', () async {
      when(
        () => mockRepository.update(id: any(named: 'id'), title: any(named: 'title'), content: any(named: 'content')),
      ).thenAnswer((_) async => Success(tNote));

      final result = await useCase.execute(id: tId, title: 'Updated Title', content: 'Updated content');

      expect(result, isA<Success<NoteEntity>>());
      expect((result as Success<NoteEntity>).value, tNote);
      verify(() => mockRepository.update(id: tId, title: 'Updated Title', content: 'Updated content')).called(1);
    });
  });
}
