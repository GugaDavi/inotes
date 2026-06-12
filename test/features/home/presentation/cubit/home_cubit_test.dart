import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/auth/domain/entities/session_entity.dart';
import 'package:inotes/features/auth/domain/errors/auth_failures.dart';
import 'package:inotes/features/auth/domain/usecases/clear_session_use_case.dart';
import 'package:inotes/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:inotes/features/home/presentation/cubit/home_cubit.dart';
import 'package:inotes/features/home/presentation/cubit/home_state.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
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

    group('search', () {
      final tLoaded = HomeLoaded(notes: [tNote, tNote2], filteredNotes: [tNote, tNote2], sessionCode: tSession.code);

      blocTest<HomeCubit, HomeState>(
        'filters by title case-insensitively after debounce',
        build: buildCubit,
        seed: () => tLoaded,
        act: (cubit) => cubit.search('flutter'),
        wait: const Duration(milliseconds: 400),
        expect: () => [
          HomeLoaded(notes: [tNote, tNote2], filteredNotes: [tNote2], sessionCode: tSession.code, query: 'flutter'),
        ],
      );

      blocTest<HomeCubit, HomeState>(
        'filters by content case-insensitively after debounce',
        build: buildCubit,
        seed: () => tLoaded,
        act: (cubit) => cubit.search('some content'),
        wait: const Duration(milliseconds: 400),
        expect: () => [
          HomeLoaded(notes: [tNote, tNote2], filteredNotes: [tNote], sessionCode: tSession.code, query: 'some content'),
        ],
      );

      blocTest<HomeCubit, HomeState>(
        'returns empty filteredNotes when no note matches',
        build: buildCubit,
        seed: () => tLoaded,
        act: (cubit) => cubit.search('xyz123'),
        wait: const Duration(milliseconds: 400),
        expect: () => [
          HomeLoaded(notes: [tNote, tNote2], filteredNotes: const [], sessionCode: tSession.code, query: 'xyz123'),
        ],
      );

      blocTest<HomeCubit, HomeState>(
        'returns all notes when query is cleared after debounce',
        build: buildCubit,
        seed: () =>
            HomeLoaded(notes: [tNote, tNote2], filteredNotes: [tNote2], sessionCode: tSession.code, query: 'flutter'),
        act: (cubit) => cubit.search(''),
        wait: const Duration(milliseconds: 400),
        expect: () => [
          HomeLoaded(notes: [tNote, tNote2], filteredNotes: [tNote, tNote2], sessionCode: tSession.code),
        ],
      );

      blocTest<HomeCubit, HomeState>(
        'only emits once for multiple rapid calls — debounce coalesces them',
        build: buildCubit,
        seed: () => tLoaded,
        act: (cubit) {
          cubit.search('f');
          cubit.search('fl');
          cubit.search('flu');
          cubit.search('flutter');
        },
        wait: const Duration(milliseconds: 400),
        expect: () => [
          HomeLoaded(notes: [tNote, tNote2], filteredNotes: [tNote2], sessionCode: tSession.code, query: 'flutter'),
        ],
      );

      blocTest<HomeCubit, HomeState>(
        'does nothing when state is not HomeLoaded',
        build: buildCubit,
        seed: () => const HomeLoading(),
        act: (cubit) => cubit.search('anything'),
        wait: const Duration(milliseconds: 400),
        expect: () => [],
      );
    });

    group('applyDateFilter', () {
      final noteDay10 = NoteEntity(
        id: '10',
        userId: tSession.code,
        title: 'Day ten',
        content: 'content',
        createdAt: DateTime(2026, 6, 10),
      );
      final noteDay11 = NoteEntity(
        id: '11',
        userId: tSession.code,
        title: 'Day eleven',
        content: 'content',
        createdAt: DateTime(2026, 6, 11),
      );
      final noteDay12 = NoteEntity(
        id: '12',
        userId: tSession.code,
        title: 'Day twelve',
        content: 'content',
        createdAt: DateTime(2026, 6, 12),
      );
      final allNotes = [noteDay10, noteDay11, noteDay12];
      final tLoaded = HomeLoaded(notes: allNotes, filteredNotes: allNotes, sessionCode: tSession.code);

      blocTest<HomeCubit, HomeState>(
        'filters to a single day',
        build: buildCubit,
        seed: () => tLoaded,
        act: (cubit) => cubit.applyDateFilter(DateRangeFilter(from: DateTime(2026, 6, 11))),
        wait: const Duration(milliseconds: 400),
        expect: () => [
          HomeLoaded(
            notes: allNotes,
            filteredNotes: [noteDay11],
            sessionCode: tSession.code,
            dateFilter: DateRangeFilter(from: DateTime(2026, 6, 11)),
          ),
        ],
      );

      blocTest<HomeCubit, HomeState>(
        'filters by date range (inclusive boundaries)',
        build: buildCubit,
        seed: () => tLoaded,
        act: (cubit) => cubit.applyDateFilter(DateRangeFilter(from: DateTime(2026, 6, 10), to: DateTime(2026, 6, 11))),
        wait: const Duration(milliseconds: 400),
        expect: () => [
          HomeLoaded(
            notes: allNotes,
            filteredNotes: [noteDay10, noteDay11],
            sessionCode: tSession.code,
            dateFilter: DateRangeFilter(from: DateTime(2026, 6, 10), to: DateTime(2026, 6, 11)),
          ),
        ],
      );

      blocTest<HomeCubit, HomeState>(
        'clears filter and returns all notes when null is passed',
        build: buildCubit,
        seed: () => HomeLoaded(
          notes: allNotes,
          filteredNotes: [noteDay11],
          sessionCode: tSession.code,
          dateFilter: DateRangeFilter(from: DateTime(2026, 6, 11)),
        ),
        act: (cubit) => cubit.applyDateFilter(null),
        wait: const Duration(milliseconds: 400),
        expect: () => [HomeLoaded(notes: allNotes, filteredNotes: allNotes, sessionCode: tSession.code)],
      );

      blocTest<HomeCubit, HomeState>(
        'combined: text search and date filter intersect',
        build: buildCubit,
        seed: () => HomeLoaded(
          notes: [tNote, tNote2],
          filteredNotes: [tNote, tNote2],
          sessionCode: tSession.code,
          query: 'note',
        ),
        act: (cubit) => cubit.applyDateFilter(DateRangeFilter(from: DateTime(2026, 6, 10))),
        wait: const Duration(milliseconds: 400),
        expect: () => [
          HomeLoaded(
            notes: [tNote, tNote2],
            filteredNotes: [tNote],
            sessionCode: tSession.code,
            query: 'note',
            dateFilter: DateRangeFilter(from: DateTime(2026, 6, 10)),
          ),
        ],
      );

      blocTest<HomeCubit, HomeState>(
        'does nothing when state is not HomeLoaded',
        build: buildCubit,
        seed: () => const HomeLoading(),
        act: (cubit) => cubit.applyDateFilter(DateRangeFilter(from: DateTime(2026, 6, 10))),
        wait: const Duration(milliseconds: 400),
        expect: () => [],
      );
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
