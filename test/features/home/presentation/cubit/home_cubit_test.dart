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
          when(() => mockGetNotesUseCase.execute(userId: any(named: 'userId')))
              .thenAnswer((_) async => Success([tNote]));
        },
        act: (cubit) => cubit.loadNotes(),
        expect: () => [const HomeLoading(), HomeLoaded([tNote], tSession.code)],
      );

      blocTest<HomeCubit, HomeState>(
        'emits [HomeLoading, HomeLoaded with empty list] when no notes exist',
        build: buildCubit,
        setUp: () {
          when(() => mockGetSessionUseCase.execute()).thenAnswer((_) async => const Success(tSession));
          when(() => mockGetNotesUseCase.execute(userId: any(named: 'userId')))
              .thenAnswer((_) async => const Success([]));
        },
        act: (cubit) => cubit.loadNotes(),
        expect: () => [const HomeLoading(), HomeLoaded(const [], tSession.code)],
      );

      blocTest<HomeCubit, HomeState>(
        'emits [HomeLoading, HomeError] when no session exists',
        build: buildCubit,
        setUp: () {
          when(() => mockGetSessionUseCase.execute())
              .thenAnswer((_) async => const Failure(SessionNotFoundFailure()));
        },
        act: (cubit) => cubit.loadNotes(),
        expect: () => [const HomeLoading(), const HomeError()],
      );

      blocTest<HomeCubit, HomeState>(
        'emits [HomeLoading, HomeError] when notes fetch fails',
        build: buildCubit,
        setUp: () {
          when(() => mockGetSessionUseCase.execute()).thenAnswer((_) async => const Success(tSession));
          when(() => mockGetNotesUseCase.execute(userId: any(named: 'userId')))
              .thenAnswer((_) async => const Failure(NoteFirestoreFailure()));
        },
        act: (cubit) => cubit.loadNotes(),
        expect: () => [const HomeLoading(), const HomeError()],
      );
    });

    group('logout', () {
      blocTest<HomeCubit, HomeState>(
        'clears session and emits HomeLoggedOut',
        build: buildCubit,
        setUp: () {
          when(() => mockClearSessionUseCase.execute())
              .thenAnswer((_) async => const Success(null));
        },
        act: (cubit) => cubit.logout(),
        expect: () => [isA<HomeLoggedOut>()],
      );

      blocTest<HomeCubit, HomeState>(
        'still emits HomeLoggedOut even when clearSession fails',
        build: buildCubit,
        setUp: () {
          when(() => mockClearSessionUseCase.execute())
              .thenAnswer((_) async => const Failure(SessionStorageFailure()));
        },
        act: (cubit) => cubit.logout(),
        expect: () => [isA<HomeLoggedOut>()],
      );
    });
  });
}
