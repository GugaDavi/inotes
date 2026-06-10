import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/domain/errors/note_failures.dart';
import 'package:inotes/features/notes/domain/usecases/create_note.dart';
import 'package:inotes/features/notes/domain/usecases/update_note.dart';
import 'package:inotes/features/notes/presentation/cubit/note_detail_cubit.dart';
import 'package:inotes/features/notes/presentation/cubit/note_detail_state.dart';

class MockCreateNote extends Mock implements CreateNote {}

class MockUpdateNote extends Mock implements UpdateNote {}

void main() {
  late MockCreateNote mockCreateNote;
  late MockUpdateNote mockUpdateNote;

  final tNote = NoteEntity(id: '1', title: 'Test Note', content: 'Some content', createdAt: DateTime(2026, 6, 10));

  setUp(() {
    mockCreateNote = MockCreateNote();
    mockUpdateNote = MockUpdateNote();
  });

  group('NoteDetailCubit', () {
    test('initial state is NoteDetailInitial', () {
      final cubit = NoteDetailCubit(mockCreateNote, mockUpdateNote);
      expect(cubit.state, isA<NoteDetailInitial>());
      cubit.close();
    });

    group('save — create mode (no id)', () {
      blocTest<NoteDetailCubit, NoteDetailState>(
        'emits [Saving, Saved] when create succeeds',
        build: () => NoteDetailCubit(mockCreateNote, mockUpdateNote),
        setUp: () {
          when(
            () => mockCreateNote.execute(
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
        build: () => NoteDetailCubit(mockCreateNote, mockUpdateNote),
        setUp: () {
          when(
            () => mockCreateNote.execute(
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
        build: () => NoteDetailCubit(mockCreateNote, mockUpdateNote),
        setUp: () {
          when(
            () => mockCreateNote.execute(
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
        build: () => NoteDetailCubit(mockCreateNote, mockUpdateNote),
        setUp: () {
          when(
            () => mockUpdateNote.execute(
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
        build: () => NoteDetailCubit(mockCreateNote, mockUpdateNote),
        setUp: () {
          when(
            () => mockUpdateNote.execute(
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
  });
}
