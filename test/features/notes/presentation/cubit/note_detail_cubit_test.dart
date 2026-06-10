import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/domain/errors/note_failures.dart';
import 'package:inotes/features/notes/domain/usecases/create_note_use_case.dart';
import 'package:inotes/features/notes/domain/usecases/delete_note_use_case.dart';
import 'package:inotes/features/notes/domain/usecases/update_note_use_case.dart';
import 'package:inotes/features/notes/presentation/cubit/note_detail_cubit.dart';
import 'package:inotes/features/notes/presentation/cubit/note_detail_state.dart';

class MockCreateNoteUseCase extends Mock implements CreateNoteUseCase {}

class MockUpdateNoteUseCase extends Mock implements UpdateNoteUseCase {}

class MockDeleteNoteUseCase extends Mock implements DeleteNoteUseCase {}

void main() {
  late MockCreateNoteUseCase mockCreateNoteUseCase;
  late MockUpdateNoteUseCase mockUpdateNoteUseCase;
  late MockDeleteNoteUseCase mockDeleteNoteUseCase;

  final tNote = NoteEntity(id: '1', title: 'Test Note', content: 'Some content', createdAt: DateTime(2026, 6, 10));

  setUp(() {
    mockCreateNoteUseCase = MockCreateNoteUseCase();
    mockUpdateNoteUseCase = MockUpdateNoteUseCase();
    mockDeleteNoteUseCase = MockDeleteNoteUseCase();
  });

  group('NoteDetailCubit', () {
    test('initial state is NoteDetailInitial', () {
      final cubit = NoteDetailCubit(mockCreateNoteUseCase, mockUpdateNoteUseCase, mockDeleteNoteUseCase);
      expect(cubit.state, isA<NoteDetailInitial>());
      cubit.close();
    });

    group('save — create mode (no id)', () {
      blocTest<NoteDetailCubit, NoteDetailState>(
        'emits [Saving, Saved] when create succeeds',
        build: () => NoteDetailCubit(mockCreateNoteUseCase, mockUpdateNoteUseCase, mockDeleteNoteUseCase),
        setUp: () {
          when(
            () => mockCreateNoteUseCase.execute(
              title: any(named: 'title'),
              content: any(named: 'content'),
            ),
          ).thenAnswer((_) async => Success(tNote));
        },
        act: (cubit) => cubit.save(title: 'Test Note', content: 'Some content'),
        expect: () => [isA<NoteDetailSaving>(), NoteDetailSaved(tNote)],
      );

      blocTest<NoteDetailCubit, NoteDetailState>(
        'emits [Saving, Error] when create returns EmptyTitleFailure',
        build: () => NoteDetailCubit(mockCreateNoteUseCase, mockUpdateNoteUseCase, mockDeleteNoteUseCase),
        setUp: () {
          when(
            () => mockCreateNoteUseCase.execute(
              title: any(named: 'title'),
              content: any(named: 'content'),
            ),
          ).thenAnswer((_) async => const Failure(EmptyTitleFailure()));
        },
        act: (cubit) => cubit.save(title: '', content: ''),
        expect: () => [isA<NoteDetailSaving>(), const NoteDetailError('Title cannot be empty.')],
      );

      blocTest<NoteDetailCubit, NoteDetailState>(
        'emits [Saving, Error] on firestore failure',
        build: () => NoteDetailCubit(mockCreateNoteUseCase, mockUpdateNoteUseCase, mockDeleteNoteUseCase),
        setUp: () {
          when(
            () => mockCreateNoteUseCase.execute(
              title: any(named: 'title'),
              content: any(named: 'content'),
            ),
          ).thenAnswer((_) async => const Failure(NoteFirestoreFailure()));
        },
        act: (cubit) => cubit.save(title: 'Note', content: ''),
        expect: () => [isA<NoteDetailSaving>(), const NoteDetailError('Failed to save note.')],
      );
    });

    group('save — edit mode (with id)', () {
      blocTest<NoteDetailCubit, NoteDetailState>(
        'emits [Saving, Saved] when update succeeds',
        build: () => NoteDetailCubit(mockCreateNoteUseCase, mockUpdateNoteUseCase, mockDeleteNoteUseCase),
        setUp: () {
          when(
            () => mockUpdateNoteUseCase.execute(
              id: any(named: 'id'),
              title: any(named: 'title'),
              content: any(named: 'content'),
            ),
          ).thenAnswer((_) async => Success(tNote));
        },
        act: (cubit) => cubit.save(id: '1', title: 'Test Note', content: 'Some content'),
        expect: () => [isA<NoteDetailSaving>(), NoteDetailSaved(tNote)],
      );

      blocTest<NoteDetailCubit, NoteDetailState>(
        'emits [Saving, Error] when update fails',
        build: () => NoteDetailCubit(mockCreateNoteUseCase, mockUpdateNoteUseCase, mockDeleteNoteUseCase),
        setUp: () {
          when(
            () => mockUpdateNoteUseCase.execute(
              id: any(named: 'id'),
              title: any(named: 'title'),
              content: any(named: 'content'),
            ),
          ).thenAnswer((_) async => const Failure(NoteFirestoreFailure()));
        },
        act: (cubit) => cubit.save(id: '1', title: 'Note', content: ''),
        expect: () => [isA<NoteDetailSaving>(), const NoteDetailError('Failed to save note.')],
      );
    });

    group('delete', () {
      blocTest<NoteDetailCubit, NoteDetailState>(
        'emits [Deleting, Deleted] when delete succeeds',
        build: () => NoteDetailCubit(mockCreateNoteUseCase, mockUpdateNoteUseCase, mockDeleteNoteUseCase),
        setUp: () {
          when(
            () => mockDeleteNoteUseCase.execute(id: any(named: 'id')),
          ).thenAnswer((_) async => const Success(null));
        },
        act: (cubit) => cubit.delete(id: '1'),
        expect: () => [isA<NoteDetailDeleting>(), isA<NoteDetailDeleted>()],
      );

      blocTest<NoteDetailCubit, NoteDetailState>(
        'emits [Deleting, Error] when delete fails',
        build: () => NoteDetailCubit(mockCreateNoteUseCase, mockUpdateNoteUseCase, mockDeleteNoteUseCase),
        setUp: () {
          when(
            () => mockDeleteNoteUseCase.execute(id: any(named: 'id')),
          ).thenAnswer((_) async => const Failure(NoteFirestoreFailure()));
        },
        act: (cubit) => cubit.delete(id: '1'),
        expect: () => [isA<NoteDetailDeleting>(), const NoteDetailError('Failed to delete note.')],
      );
    });
  });
}
