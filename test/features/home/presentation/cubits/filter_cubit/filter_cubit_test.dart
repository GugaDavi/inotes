import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/home/domain/entities/filter_options_entity.dart';
import 'package:inotes/features/home/presentation/cubits/filter_cubit/filter_cubit.dart';
import 'package:inotes/features/home/presentation/cubits/filter_cubit/filter_state.dart';
import 'package:inotes/features/shared/filter/date_range_filter.dart';
import 'package:inotes/features/shared/sort/sort_option.dart';
import 'package:inotes/features/tags/domain/entities/tag_entity.dart';
import 'package:inotes/features/tags/domain/errors/tag_failures.dart';
import 'package:inotes/features/tags/domain/usecases/get_tags_use_case.dart';

class MockGetTagsUseCase extends Mock implements GetTagsUseCase {}

void main() {
  late MockGetTagsUseCase mockGetTagsUseCase;

  const tTagWork = TagEntity(id: 'tag-work', label: 'Work', color: 0xFF000000);
  const tTagPersonal = TagEntity(id: 'tag-personal', label: 'Personal', color: 0xFF111111);

  setUp(() {
    mockGetTagsUseCase = MockGetTagsUseCase();
  });

  FilterCubit buildCubit() => FilterCubit(mockGetTagsUseCase);

  group('FilterCubit', () {
    test('initial state has null options and isActive is false', () {
      final cubit = buildCubit();
      expect(cubit.state.options, isNull);
      expect(cubit.state.isActive, isFalse);
      cubit.close();
    });

    group('applyFilters', () {
      blocTest<FilterCubit, FilterState>(
        'emits state with date filter only',
        build: buildCubit,
        act: (cubit) => cubit.applyFilters(DateRangeFilter(from: DateTime(2026, 6, 11)), []),
        expect: () => [
          FilterState(
            options: FilterOptionsEntity(dateFilter: DateRangeFilter(from: DateTime(2026, 6, 11))),
          ),
        ],
      );

      blocTest<FilterCubit, FilterState>(
        'emits state with tag filter only',
        build: buildCubit,
        act: (cubit) => cubit.applyFilters(null, ['tag-work', 'tag-personal']),
        expect: () => [
          const FilterState(options: FilterOptionsEntity(tagFilter: ['tag-work', 'tag-personal'])),
        ],
      );

      blocTest<FilterCubit, FilterState>(
        'emits state with both date and tag filters',
        build: buildCubit,
        act: (cubit) => cubit.applyFilters(DateRangeFilter(from: DateTime(2026, 6, 11)), ['tag-work']),
        expect: () => [
          FilterState(
            options: FilterOptionsEntity(
              dateFilter: DateRangeFilter(from: DateTime(2026, 6, 11)),
              tagFilter: const ['tag-work'],
            ),
          ),
        ],
      );

      blocTest<FilterCubit, FilterState>(
        'emits state with sort option',
        build: buildCubit,
        act:
            (cubit) => cubit.applyFilters(
              null,
              [],
              sortOption: const SortOption(field: SortField.title, direction: SortDirection.asc),
            ),
        expect: () => [
          const FilterState(
            options: FilterOptionsEntity(
              sortOption: SortOption(field: SortField.title, direction: SortDirection.asc),
            ),
          ),
        ],
      );

      blocTest<FilterCubit, FilterState>(
        'emits state with empty options when null date and empty tags passed',
        build: buildCubit,
        act: (cubit) => cubit.applyFilters(null, []),
        expect: () => [const FilterState(options: FilterOptionsEntity())],
      );
    });

    group('isActive', () {
      test('is false when options is null', () {
        final cubit = buildCubit();
        expect(cubit.state.isActive, isFalse);
        cubit.close();
      });

      test('is true when date filter is set', () {
        final cubit = buildCubit();
        cubit.applyFilters(DateRangeFilter(from: DateTime(2026, 6, 11)), []);
        expect(cubit.state.isActive, isTrue);
        cubit.close();
      });

      test('is true when tag filter is set', () {
        final cubit = buildCubit();
        cubit.applyFilters(null, ['tag-work']);
        expect(cubit.state.isActive, isTrue);
        cubit.close();
      });

      test('is false after date and tags are cleared', () {
        final cubit = buildCubit();
        cubit.applyFilters(DateRangeFilter(from: DateTime(2026, 6, 11)), ['tag-work']);
        cubit.applyFilters(null, []);
        expect(cubit.state.isActive, isFalse);
        cubit.close();
      });

      test('is true when sort option is set', () {
        final cubit = buildCubit();
        cubit.applyFilters(null, [], sortOption: const SortOption(field: SortField.title, direction: SortDirection.asc));
        expect(cubit.state.isActive, isTrue);
        cubit.close();
      });

      test('is false when only empty options applied after sort', () {
        final cubit = buildCubit();
        cubit.applyFilters(null, [], sortOption: const SortOption(field: SortField.title, direction: SortDirection.asc));
        cubit.applyFilters(null, []);
        expect(cubit.state.isActive, isFalse);
        cubit.close();
      });
    });

    group('loadTags', () {
      test('populates availableTags on success', () async {
        when(() => mockGetTagsUseCase.execute()).thenAnswer((_) async => const Success([tTagWork, tTagPersonal]));

        final cubit = buildCubit();
        await cubit.loadTags();

        expect(cubit.availableTags, [tTagWork, tTagPersonal]);
        cubit.close();
      });

      test('availableTags remains empty when fetch fails', () async {
        when(() => mockGetTagsUseCase.execute()).thenAnswer((_) async => const Failure(TagFirestoreFailure()));

        final cubit = buildCubit();
        await cubit.loadTags();

        expect(cubit.availableTags, isEmpty);
        cubit.close();
      });

      test('does not emit a new state (tags are not part of state)', () async {
        when(() => mockGetTagsUseCase.execute()).thenAnswer((_) async => const Success([tTagWork]));

        final states = <FilterState>[];
        final cubit = buildCubit();
        cubit.stream.listen(states.add);
        await cubit.loadTags();

        expect(states, isEmpty);
        cubit.close();
      });
    });
  });
}
