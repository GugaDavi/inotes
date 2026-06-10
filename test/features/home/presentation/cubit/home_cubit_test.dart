import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/home/presentation/cubit/home_cubit.dart';
import 'package:inotes/features/home/presentation/cubit/home_state.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/domain/errors/note_failures.dart';
import 'package:inotes/features/notes/domain/usecases/get_notes.dart';

class MockGetNotes extends Mock implements GetNotes {}

void main() {
  late MockGetNotes mockGetNotes;

  final tNote = NoteEntity(
    id: '1',
    title: 'Test Note',
    content: 'Some content',
    createdAt: DateTime(2026, 6, 10),
  );

  setUp(() {
    mockGetNotes = MockGetNotes();
  });

  group('HomeCubit', () {
    test('initial state is HomeInitial', () {
      final cubit = HomeCubit(mockGetNotes);
      expect(cubit.state, const HomeInitial());
      cubit.close();
    });

    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoading, HomeLoaded] when notes are returned',
      build: () => HomeCubit(mockGetNotes),
      setUp: () {
        when(() => mockGetNotes.execute())
            .thenAnswer((_) async => Success([tNote]));
      },
      act: (cubit) => cubit.loadNotes(),
      expect: () => [const HomeLoading(), HomeLoaded([tNote])],
    );

    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoading, HomeLoaded with empty list] when no notes exist',
      build: () => HomeCubit(mockGetNotes),
      setUp: () {
        when(() => mockGetNotes.execute())
            .thenAnswer((_) async => const Success([]));
      },
      act: (cubit) => cubit.loadNotes(),
      expect: () => [const HomeLoading(), const HomeLoaded([])],
    );

    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoading, HomeError] when repository fails',
      build: () => HomeCubit(mockGetNotes),
      setUp: () {
        when(() => mockGetNotes.execute())
            .thenAnswer((_) async => const Failure(NoteFirestoreFailure()));
      },
      act: (cubit) => cubit.loadNotes(),
      expect: () => [const HomeLoading(), const HomeError()],
    );
  });
}
