import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/domain/entities/note_tag_entity.dart';
import 'package:inotes/features/shared/filter/date_range_filter.dart';
import 'package:inotes/features/shared/filter/note_filter_helper.dart';
import 'package:inotes/features/shared/sort/sort_option.dart';

void main() {
  const tagWork = NoteTagEntity(id: 'tag-work', label: 'Work', color: 0xFF000000);
  const tagPersonal = NoteTagEntity(id: 'tag-personal', label: 'Personal', color: 0xFF111111);

  final noteA = NoteEntity(
    id: 'a',
    userId: 'u1',
    title: 'Banana',
    content: '',
    createdAt: DateTime(2026, 6, 1),
    updatedAt: DateTime(2026, 6, 10),
    tags: const [tagWork],
  );
  final noteB = NoteEntity(
    id: 'b',
    userId: 'u1',
    title: 'Apple',
    content: '',
    createdAt: DateTime(2026, 6, 5),
    tags: const [tagPersonal],
  );
  final noteC = NoteEntity(
    id: 'c',
    userId: 'u1',
    title: 'Cherry',
    content: '',
    createdAt: DateTime(2026, 6, 3),
    updatedAt: DateTime(2026, 6, 8),
  );

  final allNotes = [noteA, noteB, noteC];

  group('NoteFilterHelper.filterByDate', () {
    test('returns all notes when filter is null', () {
      final result = NoteFilterHelper.filterByDate(allNotes, null);
      expect(result, allNotes);
    });

    test('filters by createdAt', () {
      final filter = DateRangeFilter(from: DateTime(2026, 6, 3), to: DateTime(2026, 6, 5));
      final result = NoteFilterHelper.filterByDate(allNotes, filter);
      expect(result.map((n) => n.id).toList(), containsAll(['b', 'c']));
      expect(result, hasLength(2));
    });

    test('returns empty list when no notes match the range', () {
      final filter = DateRangeFilter(from: DateTime(2026, 7, 1));
      final result = NoteFilterHelper.filterByDate(allNotes, filter);
      expect(result, isEmpty);
    });
  });

  group('NoteFilterHelper.filterByTags', () {
    test('returns all notes when tagIds is empty', () {
      final result = NoteFilterHelper.filterByTags(allNotes, []);
      expect(result, allNotes);
    });

    test('keeps notes that have at least one matching tag', () {
      final result = NoteFilterHelper.filterByTags(allNotes, ['tag-work']);
      expect(result.map((n) => n.id).toList(), ['a']);
    });

    test('OR logic — keeps notes matching any of the given tags', () {
      final result = NoteFilterHelper.filterByTags(allNotes, ['tag-work', 'tag-personal']);
      expect(result.map((n) => n.id).toList(), containsAll(['a', 'b']));
      expect(result, hasLength(2));
    });

    test('returns empty list when no notes match the tags', () {
      final result = NoteFilterHelper.filterByTags(allNotes, ['tag-unknown']);
      expect(result, isEmpty);
    });
  });

  group('NoteFilterHelper.sort', () {
    test('returns notes unchanged when sortOption is null', () {
      final result = NoteFilterHelper.sort(allNotes, null);
      expect(result, allNotes);
    });

    test('does not mutate the original list', () {
      final original = List.of(allNotes);
      NoteFilterHelper.sort(allNotes, const SortOption(field: SortField.title, direction: SortDirection.asc));
      expect(allNotes, original);
    });

    test('sorts by title ascending', () {
      final result = NoteFilterHelper.sort(
        allNotes,
        const SortOption(field: SortField.title, direction: SortDirection.asc),
      );
      expect(result.map((n) => n.title).toList(), ['Apple', 'Banana', 'Cherry']);
    });

    test('sorts by title descending', () {
      final result = NoteFilterHelper.sort(
        allNotes,
        const SortOption(field: SortField.title, direction: SortDirection.desc),
      );
      expect(result.map((n) => n.title).toList(), ['Cherry', 'Banana', 'Apple']);
    });

    test('sorts by createdAt ascending', () {
      final result = NoteFilterHelper.sort(
        allNotes,
        const SortOption(field: SortField.createdAt, direction: SortDirection.asc),
      );
      expect(result.map((n) => n.id).toList(), ['a', 'c', 'b']);
    });

    test('sorts by createdAt descending', () {
      final result = NoteFilterHelper.sort(
        allNotes,
        const SortOption(field: SortField.createdAt, direction: SortDirection.desc),
      );
      expect(result.map((n) => n.id).toList(), ['b', 'c', 'a']);
    });

    test('sorts by updatedAt descending, falling back to createdAt when null', () {
      // noteA: updatedAt 2026-06-10, noteC: updatedAt 2026-06-08, noteB: fallback createdAt 2026-06-05
      final result = NoteFilterHelper.sort(
        allNotes,
        const SortOption(field: SortField.updatedAt, direction: SortDirection.desc),
      );
      expect(result.map((n) => n.id).toList(), ['a', 'c', 'b']);
    });

    test('sorts by updatedAt ascending', () {
      // noteB: fallback 2026-06-05, noteC: updatedAt 2026-06-08, noteA: updatedAt 2026-06-10
      final result = NoteFilterHelper.sort(
        allNotes,
        const SortOption(field: SortField.updatedAt, direction: SortDirection.asc),
      );
      expect(result.map((n) => n.id).toList(), ['b', 'c', 'a']);
    });
  });
}
