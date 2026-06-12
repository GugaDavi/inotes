import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inotes/core/errors/failures.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/auth/domain/entities/session_entity.dart';
import 'package:inotes/features/auth/domain/errors/auth_failures.dart';
import 'package:inotes/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/domain/entities/note_tag_entity.dart';
import 'package:inotes/features/notes/domain/errors/note_failures.dart';
import 'package:inotes/features/notes/domain/usecases/create_note_use_case.dart';
import 'package:inotes/features/notes/domain/usecases/delete_note_use_case.dart';
import 'package:inotes/features/notes/domain/usecases/update_note_use_case.dart';
import 'package:inotes/features/notes/presentation/cubit/note_detail_cubit.dart';
import 'package:inotes/features/notes/presentation/cubit/note_detail_state.dart';
import 'package:inotes/features/tags/domain/entities/tag_entity.dart';
import 'package:inotes/features/tags/domain/usecases/get_tags_use_case.dart';

class MockCreateNoteUseCase extends Mock implements CreateNoteUseCase {}

class MockUpdateNoteUseCase extends Mock implements UpdateNoteUseCase {}

class MockDeleteNoteUseCase extends Mock implements DeleteNoteUseCase {}

class MockGetCurrentSessionUseCase extends Mock implements GetCurrentSessionUseCase {}

class MockGetTagsUseCase extends Mock implements GetTagsUseCase {}

class _TagsFailureStub extends AppFailure {
  const _TagsFailureStub();

  @override
  List<Object?> get props => [];
}

void main() {
  late MockCreateNoteUseCase mockCreateNoteUseCase;
  late MockUpdateNoteUseCase mockUpdateNoteUseCase;
  late MockDeleteNoteUseCase mockDeleteNoteUseCase;
  late MockGetCurrentSessionUseCase mockGetSessionUseCase;
  late MockGetTagsUseCase mockGetTagsUseCase;

  const tSession = SessionEntity(code: 'ABCD1234');
  final tNote = NoteEntity(
    id: '1',
    userId: 'ABCD1234',
    title: 'Test Note',
    content: 'Some content',
    createdAt: DateTime(2026, 6, 10),
  );
  const tTags = [TagEntity(id: 'tag1', label: 'Work', color: 0xFF007AFF)];

  setUp(() {
    mockCreateNoteUseCase = MockCreateNoteUseCase();
    mockUpdateNoteUseCase = MockUpdateNoteUseCase();
    mockDeleteNoteUseCase = MockDeleteNoteUseCase();
    mockGetSessionUseCase = MockGetCurrentSessionUseCase();
    mockGetTagsUseCase = MockGetTagsUseCase();
  });

  NoteDetailCubit buildCubit() => NoteDetailCubit(
    mockCreateNoteUseCase,
    mockUpdateNoteUseCase,
    mockDeleteNoteUseCase,
    mockGetSessionUseCase,
    mockGetTagsUseCase,
  );

  group('NoteDetailCubit', () {
    test('initial state is NoteDetailInitial', () {
      final cubit = buildCubit();
      expect(cubit.state, isA<NoteDetailInitial>());
      cubit.close();
    });

    group('loadTags', () {
      blocTest<NoteDetailCubit, NoteDetailState>(
        'emits NoteDetailTagsLoaded with available tags on success',
        build: buildCubit,
        setUp: () {
          when(() => mockGetTagsUseCase.execute()).thenAnswer((_) async => const Success(tTags));
        },
        act: (cubit) => cubit.loadTags(),
        expect: () => [const NoteDetailTagsLoaded(availableTags: tTags, selectedTagIds: [])],
      );

      blocTest<NoteDetailCubit, NoteDetailState>(
        'pre-populates selectedTagIds from initialTags',
        build: buildCubit,
        setUp: () {
          when(() => mockGetTagsUseCase.execute()).thenAnswer((_) async => const Success(tTags));
        },
        act: (cubit) => cubit.loadTags(
          initialTags: [const NoteTagEntity(id: 'tag1', label: 'Work', color: 0xFF007AFF)],
        ),
        expect: () => [
          const NoteDetailTagsLoaded(availableTags: tTags, selectedTagIds: ['tag1']),
        ],
      );

      blocTest<NoteDetailCubit, NoteDetailState>(
        'emits NoteDetailTagsLoaded with empty lists on failure',
        build: buildCubit,
        setUp: () {
          when(() => mockGetTagsUseCase.execute()).thenAnswer((_) async => const Failure(_TagsFailureStub()));
        },
        act: (cubit) => cubit.loadTags(),
        expect: () => [const NoteDetailTagsLoaded(availableTags: [], selectedTagIds: [])],
      );
    });

    group('toggleTag', () {
      blocTest<NoteDetailCubit, NoteDetailState>(
        'adds tag to selection when not already selected',
        build: buildCubit,
        setUp: () {
          when(() => mockGetTagsUseCase.execute()).thenAnswer((_) async => const Success(tTags));
        },
        act: (cubit) async {
          await cubit.loadTags();
          cubit.toggleTag('tag1', label: 'Work', color: 0xFF007AFF);
        },
        expect: () => [
          const NoteDetailTagsLoaded(availableTags: tTags, selectedTagIds: []),
          const NoteDetailTagsLoaded(availableTags: tTags, selectedTagIds: ['tag1']),
        ],
      );

      blocTest<NoteDetailCubit, NoteDetailState>(
        'removes tag from selection when already selected',
        build: buildCubit,
        setUp: () {
          when(() => mockGetTagsUseCase.execute()).thenAnswer((_) async => const Success(tTags));
        },
        act: (cubit) async {
          await cubit.loadTags(
            initialTags: [const NoteTagEntity(id: 'tag1', label: 'Work', color: 0xFF007AFF)],
          );
          cubit.toggleTag('tag1', label: 'Work', color: 0xFF007AFF);
        },
        expect: () => [
          const NoteDetailTagsLoaded(availableTags: tTags, selectedTagIds: ['tag1']),
          const NoteDetailTagsLoaded(availableTags: tTags, selectedTagIds: []),
        ],
      );

      blocTest<NoteDetailCubit, NoteDetailState>(
        'does not add a 4th tag when 3 are already selected',
        build: buildCubit,
        setUp: () {
          when(() => mockGetTagsUseCase.execute()).thenAnswer(
            (_) async => const Success([
              TagEntity(id: 'tag1', label: 'Work', color: 0xFF007AFF),
              TagEntity(id: 'tag2', label: 'Personal', color: 0xFF5E5CE6),
              TagEntity(id: 'tag3', label: 'Ideas', color: 0xFFFFCC00),
              TagEntity(id: 'tag4', label: 'Study', color: 0xFF30D158),
            ]),
          );
        },
        act: (cubit) async {
          await cubit.loadTags(
            initialTags: [
              const NoteTagEntity(id: 'tag1', label: 'Work', color: 0xFF007AFF),
              const NoteTagEntity(id: 'tag2', label: 'Personal', color: 0xFF5E5CE6),
              const NoteTagEntity(id: 'tag3', label: 'Ideas', color: 0xFFFFCC00),
            ],
          );
          cubit.toggleTag('tag4', label: 'Study', color: 0xFF30D158);
        },
        expect: () => [isA<NoteDetailTagsLoaded>().having((s) => s.selectedTagIds.length, 'count', 3)],
      );
    });

    group('save — create mode (no id)', () {
      blocTest<NoteDetailCubit, NoteDetailState>(
        'emits [Saving, Saved] when create succeeds',
        build: buildCubit,
        setUp: () {
          when(() => mockGetSessionUseCase.execute()).thenAnswer((_) async => const Success(tSession));
          when(
            () => mockCreateNoteUseCase.execute(
              userId: any(named: 'userId'),
              title: any(named: 'title'),
              content: any(named: 'content'),
              tags: any(named: 'tags'),
            ),
          ).thenAnswer((_) async => Success(tNote));
        },
        act: (cubit) => cubit.save(title: 'Test Note', content: 'Some content'),
        expect: () => [isA<NoteDetailSaving>(), NoteDetailSaved(tNote)],
      );

      blocTest<NoteDetailCubit, NoteDetailState>(
        'emits [Saving, Error] when no session exists',
        build: buildCubit,
        setUp: () {
          when(() => mockGetSessionUseCase.execute()).thenAnswer((_) async => const Failure(SessionNotFoundFailure()));
        },
        act: (cubit) => cubit.save(title: 'Test Note', content: 'Content'),
        expect: () => [isA<NoteDetailSaving>(), isA<NoteDetailError>()],
      );

      blocTest<NoteDetailCubit, NoteDetailState>(
        'emits [Saving, Error] when create returns EmptyTitleFailure',
        build: buildCubit,
        setUp: () {
          when(() => mockGetSessionUseCase.execute()).thenAnswer((_) async => const Success(tSession));
          when(
            () => mockCreateNoteUseCase.execute(
              userId: any(named: 'userId'),
              title: any(named: 'title'),
              content: any(named: 'content'),
              tags: any(named: 'tags'),
            ),
          ).thenAnswer((_) async => const Failure(EmptyTitleFailure()));
        },
        act: (cubit) => cubit.save(title: '', content: ''),
        expect: () => [isA<NoteDetailSaving>(), const NoteDetailError('Title cannot be empty.')],
      );

      blocTest<NoteDetailCubit, NoteDetailState>(
        'emits [Saving, Error] on firestore failure',
        build: buildCubit,
        setUp: () {
          when(() => mockGetSessionUseCase.execute()).thenAnswer((_) async => const Success(tSession));
          when(
            () => mockCreateNoteUseCase.execute(
              userId: any(named: 'userId'),
              title: any(named: 'title'),
              content: any(named: 'content'),
              tags: any(named: 'tags'),
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
        build: buildCubit,
        setUp: () {
          when(() => mockGetSessionUseCase.execute()).thenAnswer((_) async => const Success(tSession));
          when(
            () => mockUpdateNoteUseCase.execute(
              id: any(named: 'id'),
              title: any(named: 'title'),
              content: any(named: 'content'),
              tags: any(named: 'tags'),
            ),
          ).thenAnswer((_) async => Success(tNote));
        },
        act: (cubit) => cubit.save(id: '1', title: 'Test Note', content: 'Some content'),
        expect: () => [isA<NoteDetailSaving>(), NoteDetailSaved(tNote)],
      );

      blocTest<NoteDetailCubit, NoteDetailState>(
        'emits [Saving, Error] when update fails',
        build: buildCubit,
        setUp: () {
          when(() => mockGetSessionUseCase.execute()).thenAnswer((_) async => const Success(tSession));
          when(
            () => mockUpdateNoteUseCase.execute(
              id: any(named: 'id'),
              title: any(named: 'title'),
              content: any(named: 'content'),
              tags: any(named: 'tags'),
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
        build: buildCubit,
        setUp: () {
          when(() => mockDeleteNoteUseCase.execute(id: any(named: 'id'))).thenAnswer((_) async => const Success(null));
        },
        act: (cubit) => cubit.delete(id: '1'),
        expect: () => [isA<NoteDetailDeleting>(), isA<NoteDetailDeleted>()],
      );

      blocTest<NoteDetailCubit, NoteDetailState>(
        'emits [Deleting, Error] when delete fails',
        build: buildCubit,
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
