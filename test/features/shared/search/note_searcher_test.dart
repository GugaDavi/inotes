import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/shared/search/note_searcher.dart';

void main() {
  final tNote = NoteEntity(
    id: '1',
    userId: 'user',
    title: 'Test Note',
    content: 'Some content',
    createdAt: DateTime(2026, 6, 10),
  );
  final tNote2 = NoteEntity(
    id: '2',
    userId: 'user',
    title: 'Flutter tips',
    content: 'Use widgets wisely',
    createdAt: DateTime(2026, 6, 11),
  );

  group('NoteSearcher', () {
    test('calls onResult with notes filtered by title after debounce', () async {
      List<NoteEntity>? result;
      final searcher = NoteSearcher(onResult: (filtered, _) => result = filtered);

      searcher.search([tNote, tNote2], 'flutter');
      await Future.delayed(const Duration(milliseconds: 400));

      expect(result, [tNote2]);
      searcher.dispose();
    });

    test('calls onResult with notes filtered by content after debounce', () async {
      List<NoteEntity>? result;
      final searcher = NoteSearcher(onResult: (filtered, _) => result = filtered);

      searcher.search([tNote, tNote2], 'some content');
      await Future.delayed(const Duration(milliseconds: 400));

      expect(result, [tNote]);
      searcher.dispose();
    });

    test('calls onResult with all notes when query is empty', () async {
      List<NoteEntity>? result;
      final searcher = NoteSearcher(onResult: (filtered, _) => result = filtered);

      searcher.search([tNote, tNote2], '');
      await Future.delayed(const Duration(milliseconds: 400));

      expect(result, [tNote, tNote2]);
      searcher.dispose();
    });

    test('calls onResult with empty list when no note matches', () async {
      List<NoteEntity>? result;
      final searcher = NoteSearcher(onResult: (filtered, _) => result = filtered);

      searcher.search([tNote, tNote2], 'xyz123');
      await Future.delayed(const Duration(milliseconds: 400));

      expect(result, isEmpty);
      searcher.dispose();
    });

    test('coalesces rapid calls and only invokes onResult once', () async {
      var callCount = 0;
      String? lastQuery;
      final searcher = NoteSearcher(
        onResult: (_, query) {
          callCount++;
          lastQuery = query;
        },
      );

      searcher.search([tNote, tNote2], 'f');
      searcher.search([tNote, tNote2], 'fl');
      searcher.search([tNote, tNote2], 'flu');
      searcher.search([tNote, tNote2], 'flutter');
      await Future.delayed(const Duration(milliseconds: 400));

      expect(callCount, 1);
      expect(lastQuery, 'flutter');
      searcher.dispose();
    });

    test('dispose cancels pending search before it fires', () async {
      var called = false;
      final searcher = NoteSearcher(onResult: (_, __) => called = true);

      searcher.search([tNote], 'flutter');
      searcher.dispose();
      await Future.delayed(const Duration(milliseconds: 400));

      expect(called, false);
    });

    test('passes the query string to onResult', () async {
      String? resultQuery;
      final searcher = NoteSearcher(onResult: (_, query) => resultQuery = query);

      searcher.search([tNote, tNote2], 'flutter');
      await Future.delayed(const Duration(milliseconds: 400));

      expect(resultQuery, 'flutter');
      searcher.dispose();
    });
  });
}
