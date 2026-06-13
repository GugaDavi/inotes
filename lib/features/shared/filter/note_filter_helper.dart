import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/shared/filter/date_range_filter.dart';
import 'package:inotes/features/shared/sort/sort_option.dart';

abstract final class NoteFilterHelper {
  static List<NoteEntity> filterByDate(List<NoteEntity> notes, DateRangeFilter? filter) {
    if (filter == null) return notes;
    return notes.where((note) => filter.matches(note.createdAt)).toList();
  }

  static List<NoteEntity> filterByTags(List<NoteEntity> notes, List<String> tagIds) {
    if (tagIds.isEmpty) return notes;
    return notes.where((note) => note.tags.any((t) => tagIds.contains(t.id))).toList();
  }

  static List<NoteEntity> sort(List<NoteEntity> notes, SortOption? option) {
    if (option == null) return notes;
    return List.of(notes)..sort((a, b) {
      final cmp = switch (option.field) {
        SortField.createdAt => a.createdAt.compareTo(b.createdAt),
        SortField.updatedAt => (a.updatedAt ?? a.createdAt).compareTo(b.updatedAt ?? b.createdAt),
        SortField.title => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      };
      return option.direction == SortDirection.asc ? cmp : -cmp;
    });
  }
}
