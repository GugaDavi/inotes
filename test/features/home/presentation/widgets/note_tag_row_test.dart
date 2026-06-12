import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/features/home/presentation/widgets/note_tag_row.dart';
import 'package:inotes/features/notes/domain/entities/note_tag_entity.dart';

Widget _wrap(Widget child) => CupertinoApp(home: CupertinoPageScaffold(child: child));

const _tTags = [
  NoteTagEntity(id: 'tag1', label: 'Work', color: 0xFF007AFF),
  NoteTagEntity(id: 'tag2', label: 'Personal', color: 0xFF5E5CE6),
];

void main() {
  group('NoteTagRow', () {
    testWidgets('renders label for each tag', (tester) async {
      await tester.pumpWidget(_wrap(const NoteTagRow(tags: _tTags)));

      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);
    });

    testWidgets('renders a single tag correctly', (tester) async {
      const single = [NoteTagEntity(id: 'tag1', label: 'Study', color: 0xFF30D158)];
      await tester.pumpWidget(_wrap(const NoteTagRow(tags: single)));

      expect(find.text('Study'), findsOneWidget);
    });

    testWidgets('renders nothing when tags list is empty', (tester) async {
      await tester.pumpWidget(_wrap(const NoteTagRow(tags: [])));

      expect(find.byType(Text), findsNothing);
    });
  });
}
