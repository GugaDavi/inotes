import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/domain/errors/note_failures.dart';
import 'package:inotes/features/notes/domain/repositories/notes_repository.dart';
import 'package:inotes/features/notes/domain/usecases/get_note_by_id_use_case.dart';

class MockNotesRepository extends Mock implements NotesRepository {}

void main() {
  late GetNoteByIdUseCase useCase;
  late MockNotesRepository mockRepository;

  setUp(() {
    mockRepository = MockNotesRepository();
    useCase = GetNoteByIdUseCase(mockRepository);
  });

  final tNote = NoteEntity(
    id: 'note-1',
    userId: 'user-a',
    title: 'Deep Link Note',
    content: 'Accessed by ID',
    createdAt: DateTime(2026, 6, 10),
  );

  group('GetNoteByIdUseCase', () {
    test('returns Success with note when found', () async {
      when(() => mockRepository.getById(id: any(named: 'id'))).thenAnswer((_) async => Success(tNote));

      final result = await useCase.execute(id: 'note-1');

      expect(result, isA<Success<NoteEntity>>());
      expect((result as Success<NoteEntity>).value, tNote);
      verify(() => mockRepository.getById(id: 'note-1')).called(1);
    });

    test('returns Failure when note is not found', () async {
      when(
        () => mockRepository.getById(id: any(named: 'id')),
      ).thenAnswer((_) async => const Failure(NoteNotFoundFailure()));

      final result = await useCase.execute(id: 'missing-id');

      expect(result, isA<Failure<NoteEntity>>());
    });

    test('returns Failure on firestore error', () async {
      when(
        () => mockRepository.getById(id: any(named: 'id')),
      ).thenAnswer((_) async => const Failure(NoteFirestoreFailure()));

      final result = await useCase.execute(id: 'note-1');

      expect(result, isA<Failure<NoteEntity>>());
    });
  });
}
