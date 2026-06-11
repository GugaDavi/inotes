import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/notes/domain/errors/note_failures.dart';
import 'package:inotes/features/notes/domain/repositories/notes_repository.dart';
import 'package:inotes/features/notes/domain/usecases/delete_note_use_case.dart';

class MockNotesRepository extends Mock implements NotesRepository {}

void main() {
  late DeleteNoteUseCase useCase;
  late MockNotesRepository mockRepository;

  setUp(() {
    mockRepository = MockNotesRepository();
    useCase = DeleteNoteUseCase(mockRepository);
  });

  group('DeleteNoteUseCase', () {
    const tId = '1';

    test('should call repository and return Success when deletion succeeds', () async {
      when(() => mockRepository.delete(id: tId)).thenAnswer((_) async => Success<void>(null));

      final result = await useCase.execute(id: tId);

      expect(result, isA<Success<void>>());
      verify(() => mockRepository.delete(id: tId)).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(
        () => mockRepository.delete(id: tId),
      ).thenAnswer((_) async => Failure(NoteFirestoreFailure('firestore error')));

      final result = await useCase.execute(id: tId);

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).failure, isA<NoteFirestoreFailure>());
    });
  });
}
