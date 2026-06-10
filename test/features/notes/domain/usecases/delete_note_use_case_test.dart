import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:inotes/core/result/result.dart';
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
  });
}
