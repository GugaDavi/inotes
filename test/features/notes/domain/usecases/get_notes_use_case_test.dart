import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
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
      NoteEntity(id: '1', title: 'First Note', content: 'First content', createdAt: DateTime(2026, 6, 9)),
      NoteEntity(id: '2', title: 'Second Note', content: 'Second content', createdAt: DateTime(2026, 6, 10)),
    ];

    test('should return Success with list of notes', () async {
      when(() => mockRepository.getAll()).thenAnswer((_) async => Success(tNotes));

      final result = await useCase.execute();

      expect(result, isA<Success<List<NoteEntity>>>());
      expect((result as Success<List<NoteEntity>>).value, tNotes);
      verify(() => mockRepository.getAll()).called(1);
    });

    test('should return Success with empty list when there are no notes', () async {
      when(() => mockRepository.getAll()).thenAnswer((_) async => Success([]));

      final result = await useCase.execute();

      expect(result, isA<Success<List<NoteEntity>>>());
      expect((result as Success<List<NoteEntity>>).value, isEmpty);
      verify(() => mockRepository.getAll()).called(1);
    });
  });
}
