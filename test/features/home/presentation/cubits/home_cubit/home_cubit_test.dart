import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/auth/domain/entities/session_entity.dart';
import 'package:inotes/features/auth/domain/errors/auth_failures.dart';
import 'package:inotes/features/auth/domain/usecases/clear_session_use_case.dart';
import 'package:inotes/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:inotes/features/home/domain/entities/filter_options_entity.dart';
import 'package:inotes/features/home/presentation/cubits/home_cubit/home_cubit.dart';
import 'package:inotes/features/home/presentation/cubits/home_cubit/home_state.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/domain/entities/note_tag_entity.dart';
import 'package:inotes/features/notes/domain/errors/note_failures.dart';
import 'package:inotes/features/notes/domain/usecases/get_notes_use_case.dart';
import 'package:inotes/features/shared/filter/date_range_filter.dart';

class MockGetNotesUseCase extends Mock implements GetNotesUseCase {}

class MockGetCurrentSessionUseCase extends Mock implements GetCurrentSessionUseCase {}

class MockClearSessionUseCase extends Mock implements ClearSessionUseCase {}

void main() {
  late MockGetNotesUseCase mockGetNotesUseCase;
  late MockGetCurrentSessionUseCase mockGetSessionUseCase;
  late MockClearSessionUseCase mockClearSessionUseCase;

  const tSession = SessionEntity(code: 'ABCD1234');
  final tNote = NoteEntity(
    id: '1',
    userId: 'ABCD1234',
    title: 'Test Note',
    content: 'Some content',
    createdAt: DateTime(2026, 6, 10),
  );
  final tNote2 = NoteEntity(
    id: '2',
    userId: 'ABCD1234',
    title: 'Flutter tips',
    content: 'Use widgets wisely',
    createdAt: DateTime(2026, 6, 11),
  );

  setUp(() {
    mockGetNotesUseCase = MockGetNotesUseCase();
    mockGetSessionUseCase = MockGetCurrentSessionUseCase();
    mockClearSessionUseCase = MockClearSessionUseCase();
  });

  HomeCubit buildCubit() => HomeCubit(mockGetNotesUseCase, mockGetSessionUseCase, mockClearSessionUseCase);

  group('HomeCubit', () {
    test('initial state is HomeInitial', () {
      final cubit = buildCubit();
      expect(cubit.state, const HomeInitial());
      cubit.close();
    });

    group('loadNotes', () {
      blocTest<HomeCubit, HomeState>(
        'emits [HomeLoading, HomeLoaded] with notes and sessionCode when successful',
        build: buildCubit,
        setUp: () {
          when(() => mockGetSessionUseCase.execute()).thenAnswer((_) async => const Success(tSession));
          when(
            () => mockGetNotesUseCase.execute(userId: any(named: 'userId')),
          ).thenAnswer((_) async => Success([tNote]));
        },
        act: (cubit) => cubit.loadNotes(),
        expect: () => [
          const HomeLoading(),
          HomeLoaded(notes: [tNote], filteredNotes: [tNote], sessionCode: tSession.code),
        ],
      );

      blocTest<HomeCubit, HomeState>(
        'emits [HomeLoading, HomeLoaded with empty list] when no notes exist',
        build: buildCubit,
        setUp: () {
          when(() => mockGetSessionUseCase.execute()).thenAnswer((_) async => const Success(tSession));
          when(
            () => mockGetNotesUseCase.execute(userId: any(named: 'userId')),
          ).thenAnswer((_) async => const Success([]));
        },
        act: (cubit) => cubit.loadNotes(),
        expect: () => [
          const HomeLoading(),
          HomeLoaded(notes: const [], filteredNotes: const [], sessionCode: tSession.code),
        ],
      );

      blocTest<HomeCubit, HomeState>(
        'emits [HomeLoading, HomeError] when no session exists',
        build: buildCubit,
        setUp: () {
          when(() => mockGetSessionUseCase.execute()).thenAnswer((_) async => const Failure(SessionNotFoundFailure()));
        },
        act: (cubit) => cubit.loadNotes(),
        expect: () => [const HomeLoading(), const HomeError()],
      );

      blocTest<HomeCubit, HomeState>(
        'emits [HomeLoading, HomeError] when notes fetch fails',
        build: buildCubit,
        setUp: () {
          when(() => mockGetSessionUseCase.execute()).thenAnswer((_) async => const Success(tSession));
          when(
            () => mockGetNotesUseCase.execute(userId: any(named: 'userId')),
          ).thenAnswer((_) async => const Failure(NoteFirestoreFailure()));
        },
        act: (cubit) => cubit.loadNotes(),
        expect: () => [const HomeLoading(), const HomeError()],
      );

      blocTest<HomeCubit, HomeState>(
        'applies stored filter options when loading notes',
        build: buildCubit,
        setUp: () {
          when(() => mockGetSessionUseCase.execute()).thenAnswer((_) async => const Success(tSession));
          when(
            () => mockGetNotesUseCase.execute(userId: any(named: 'userId')),
          ).thenAnswer((_) async => Success([tNote, tNote2]));
        },
        act: (cubit) async {
          cubit.handleFilterChange(FilterOptionsEntity(dateFilter: DateRangeFilter(from: DateTime(2026, 6, 11))));
          await cubit.loadNotes();
        },
        expect: () => [
          const HomeLoading(),
          HomeLoaded(notes: [tNote, tNote2], filteredNotes: [tNote2], sessionCode: tSession.code),
        ],
      );
    });

    group('sessionCode field', () {
      test('is set after successful loadNotes', () async {
        when(() => mockGetSessionUseCase.execute()).thenAnswer((_) async => const Success(tSession));
        when(
          () => mockGetNotesUseCase.execute(userId: any(named: 'userId')),
        ).thenAnswer((_) async => const Success([]));

        final cubit = buildCubit();
        await cubit.loadNotes();
        expect(cubit.sessionCode, tSession.code);
        cubit.close();
      });

      test('is set even when notes fetch fails', () async {
        when(() => mockGetSessionUseCase.execute()).thenAnswer((_) async => const Success(tSession));
        when(
          () => mockGetNotesUseCase.execute(userId: any(named: 'userId')),
        ).thenAnswer((_) async => const Failure(NoteFirestoreFailure()));

        final cubit = buildCubit();
        await cubit.loadNotes();
        expect(cubit.sessionCode, tSession.code);
        cubit.close();
      });

      test('is null when session is not found', () async {
        when(() => mockGetSessionUseCase.execute()).thenAnswer((_) async => const Failure(SessionNotFoundFailure()));

        final cubit = buildCubit();
        await cubit.loadNotes();
        expect(cubit.sessionCode, isNull);
        cubit.close();
      });

      test('is cleared after logout', () async {
        when(() => mockGetSessionUseCase.execute()).thenAnswer((_) async => const Success(tSession));
        when(
          () => mockGetNotesUseCase.execute(userId: any(named: 'userId')),
        ).thenAnswer((_) async => const Success([]));
        when(() => mockClearSessionUseCase.execute()).thenAnswer((_) async => const Success(null));

        final cubit = buildCubit();
        await cubit.loadNotes();
        expect(cubit.sessionCode, tSession.code);
        await cubit.logout();
        expect(cubit.sessionCode, isNull);
        cubit.close();
      });
    });

    group('handleFilterChange', () {
      const tagWork = NoteTagEntity(id: 'tag-work', label: 'Work', color: 0xFF000000);
      final noteWithTag = NoteEntity(
        id: '10',
        userId: tSession.code,
        title: 'Tagged',
        content: 'content',
        createdAt: DateTime(2026, 6, 10),
        tags: const [tagWork],
      );
      final noteWithoutTag = NoteEntity(
        id: '11',
        userId: tSession.code,
        title: 'Flutter tips',
        content: 'content',
        createdAt: DateTime(2026, 6, 11),
      );
      final allNotes = [noteWithTag, noteWithoutTag];

      test('re-filters by date when called with a date filter', () async {
        when(() => mockGetSessionUseCase.execute()).thenAnswer((_) async => const Success(tSession));
        when(
          () => mockGetNotesUseCase.execute(userId: any(named: 'userId')),
        ).thenAnswer((_) async => Success(allNotes));

        final cubit = buildCubit();
        await cubit.loadNotes();

        cubit.handleFilterChange(
          FilterOptionsEntity(
            dateFilter: DateRangeFilter(from: DateTime(2026, 6, 10), to: DateTime(2026, 6, 10)),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 400));

        expect((cubit.state as HomeLoaded).filteredNotes, [noteWithTag]);
        cubit.close();
      });

      test('re-filters by tag when called with a tag filter', () async {
        when(() => mockGetSessionUseCase.execute()).thenAnswer((_) async => const Success(tSession));
        when(
          () => mockGetNotesUseCase.execute(userId: any(named: 'userId')),
        ).thenAnswer((_) async => Success(allNotes));

        final cubit = buildCubit();
        await cubit.loadNotes();

        cubit.handleFilterChange(const FilterOptionsEntity(tagFilter: ['tag-work']));

        await Future.delayed(const Duration(milliseconds: 400));

        expect((cubit.state as HomeLoaded).filteredNotes, [noteWithTag]);
        cubit.close();
      });

      test('clears filters and shows all notes when called with null', () async {
        when(() => mockGetSessionUseCase.execute()).thenAnswer((_) async => const Success(tSession));
        when(
          () => mockGetNotesUseCase.execute(userId: any(named: 'userId')),
        ).thenAnswer((_) async => Success(allNotes));

        final cubit = buildCubit();
        await cubit.loadNotes();

        cubit.handleFilterChange(const FilterOptionsEntity(tagFilter: ['tag-work']));
        await Future.delayed(const Duration(milliseconds: 400));
        expect((cubit.state as HomeLoaded).filteredNotes, [noteWithTag]);

        cubit.handleFilterChange(null);
        await Future.delayed(const Duration(milliseconds: 400));
        expect((cubit.state as HomeLoaded).filteredNotes, allNotes);
        cubit.close();
      });

      test('does nothing when state is not HomeLoaded', () async {
        final cubit = buildCubit();
        cubit.handleFilterChange(FilterOptionsEntity(dateFilter: DateRangeFilter(from: DateTime(2026, 6, 10))));

        await Future.delayed(const Duration(milliseconds: 400));

        expect(cubit.state, const HomeInitial());
        cubit.close();
      });

      test('preserves active text query when filter changes', () async {
        when(() => mockGetSessionUseCase.execute()).thenAnswer((_) async => const Success(tSession));
        when(
          () => mockGetNotesUseCase.execute(userId: any(named: 'userId')),
        ).thenAnswer((_) async => Success(allNotes));

        final cubit = buildCubit();
        await cubit.loadNotes();

        // Apply text query first
        cubit.applyFilter('flutter');
        await Future.delayed(const Duration(milliseconds: 400));
        expect((cubit.state as HomeLoaded).filteredNotes, [noteWithoutTag]);

        // Now apply tag filter — should still respect the query
        cubit.handleFilterChange(const FilterOptionsEntity(tagFilter: ['tag-work']));
        await Future.delayed(const Duration(milliseconds: 400));

        // "Flutter tips" matches text but not tag; "Tagged" matches tag but not text
        expect((cubit.state as HomeLoaded).filteredNotes, isEmpty);
        cubit.close();
      });
    });

    group('applyFilter', () {
      const tagWork = NoteTagEntity(id: 'tag-work', label: 'Work', color: 0xFF000000);
      final noteWithTag = NoteEntity(
        id: '10',
        userId: tSession.code,
        title: 'Tagged',
        content: 'content',
        createdAt: DateTime(2026, 6, 10),
        tags: const [tagWork],
      );
      final noteWithoutTag = NoteEntity(
        id: '11',
        userId: tSession.code,
        title: 'Flutter tips',
        content: 'content',
        createdAt: DateTime(2026, 6, 11),
      );
      final allNotes = [noteWithTag, noteWithoutTag];

      test('filters notes by text query after debounce', () async {
        when(() => mockGetSessionUseCase.execute()).thenAnswer((_) async => const Success(tSession));
        when(
          () => mockGetNotesUseCase.execute(userId: any(named: 'userId')),
        ).thenAnswer((_) async => Success(allNotes));

        final cubit = buildCubit();
        await cubit.loadNotes();
        expect((cubit.state as HomeLoaded).filteredNotes, allNotes);

        cubit.applyFilter('flutter');

        await Future.delayed(const Duration(milliseconds: 400));

        expect((cubit.state as HomeLoaded).filteredNotes, [noteWithoutTag]);
        cubit.close();
      });

      test('does nothing when state is not HomeLoaded', () async {
        final cubit = buildCubit();
        cubit.applyFilter('flutter');

        await Future.delayed(const Duration(milliseconds: 400));

        expect(cubit.state, const HomeInitial());
        cubit.close();
      });
    });

    group('logout', () {
      blocTest<HomeCubit, HomeState>(
        'clears session and emits HomeLoggedOut',
        build: buildCubit,
        setUp: () {
          when(() => mockClearSessionUseCase.execute()).thenAnswer((_) async => const Success(null));
        },
        act: (cubit) => cubit.logout(),
        expect: () => [isA<HomeLoggedOut>()],
      );

      blocTest<HomeCubit, HomeState>(
        'still emits HomeLoggedOut even when clearSession fails',
        build: buildCubit,
        setUp: () {
          when(() => mockClearSessionUseCase.execute()).thenAnswer((_) async => const Failure(SessionStorageFailure()));
        },
        act: (cubit) => cubit.logout(),
        expect: () => [isA<HomeLoggedOut>()],
      );
    });
  });
}
