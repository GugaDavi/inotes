import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/features/home/presentation/widgets/note_list_tile.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';

NoteEntity _note({String title = 'My Note', String content = 'Some content'}) => NoteEntity(
  id: '1',
  title: title,
  content: content,
  createdAt: DateTime(2020, 1, 1),
);

Widget _wrap(Widget child) => CupertinoApp(home: CupertinoPageScaffold(child: child));

void main() {
  group('NoteListTile', () {
    testWidgets('renders the note title', (tester) async {
      await tester.pumpWidget(_wrap(NoteListTile(note: _note(title: 'Shopping list'), onTap: () {})));

      expect(find.text('Shopping list'), findsOneWidget);
    });

    testWidgets('shows New Note when title is empty', (tester) async {
      await tester.pumpWidget(_wrap(NoteListTile(note: _note(title: ''), onTap: () {})));

      expect(find.text('New Note'), findsOneWidget);
    });

    testWidgets('renders the note content', (tester) async {
      await tester.pumpWidget(_wrap(NoteListTile(note: _note(content: 'Buy milk'), onTap: () {})));

      expect(find.text('Buy milk'), findsOneWidget);
    });

    testWidgets('shows No additional text when content is empty', (tester) async {
      await tester.pumpWidget(_wrap(NoteListTile(note: _note(content: ''), onTap: () {})));

      expect(find.text('No additional text'), findsOneWidget);
    });

    testWidgets('renders the formatted date', (tester) async {
      await tester.pumpWidget(_wrap(NoteListTile(note: _note(), onTap: () {})));

      // createdAt is 2020-01-01, which is always > 7 days ago → 1/1/2020
      expect(find.text('1/1/2020'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var called = false;

      await tester.pumpWidget(_wrap(NoteListTile(note: _note(), onTap: () => called = true)));

      await tester.tap(find.byType(NoteListTile));
      expect(called, isTrue);
    });
  });
}
