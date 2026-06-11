import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/domain/errors/note_failures.dart';
import 'package:inotes/features/notes/domain/repositories/notes_repository.dart';
import 'package:inotes/features/notes/domain/usecases/get_notes_use_case.dart';

class MockNotesRepository extends Mock implements NotesRepository {}

void main() {
  late GetNotesUseCase useCase;
  late MockNotesRepository mockRepository;

  setUp(() {
    mockRepository = MockNotesRepository();
    useCase = GetNotesUseCase(mockRepository);
  });

  group('GetNotesUseCase', () {
    final tNotes = [
      NoteEntity(
        id: '1',
        userId: 'user-a',
        title: 'First Note',
        content: 'First content',
        createdAt: DateTime(2026, 6, 9),
      ),
      NoteEntity(
        id: '2',
        userId: 'user-a',
        title: 'Second Note',
        content: 'Second content',
        createdAt: DateTime(2026, 6, 10),
      ),
    ];

    test('should return Success with list of notes for given userId', () async {
      when(() => mockRepository.getAll(userId: any(named: 'userId'))).thenAnswer((_) async => Success(tNotes));

      final result = await useCase.execute(userId: 'user-a');

      expect(result, isA<Success<List<NoteEntity>>>());
      expect((result as Success<List<NoteEntity>>).value, tNotes);
      verify(() => mockRepository.getAll(userId: 'user-a')).called(1);
    });

    test('should return Success with empty list when there are no notes', () async {
      when(() => mockRepository.getAll(userId: any(named: 'userId'))).thenAnswer((_) async => const Success([]));

      final result = await useCase.execute(userId: 'user-a');

      expect(result, isA<Success<List<NoteEntity>>>());
      expect((result as Success<List<NoteEntity>>).value, isEmpty);
    });

    test('should return Failure when repository fails', () async {
      when(
        () => mockRepository.getAll(userId: any(named: 'userId')),
      ).thenAnswer((_) async => Failure(NoteFirestoreFailure('firestore error')));

      final result = await useCase.execute(userId: 'user-a');

      expect(result, isA<Failure<List<NoteEntity>>>());
      expect((result as Failure<List<NoteEntity>>).failure, isA<NoteFirestoreFailure>());
    });
  });
}
