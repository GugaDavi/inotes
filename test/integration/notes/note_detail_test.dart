import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/core/app.dart';

import '../helpers/fake_app_bootstrap.dart';

Finder _titleField() => find.byWidgetPredicate(
  (w) => w is CupertinoTextField && w.placeholder == 'Title',
);

Finder _contentField() => find.byWidgetPredicate(
  (w) => w is CupertinoTextField && w.placeholder == 'Start typing…',
);

void main() {
  group('NoteDetail - create', () {
    late AppTestSetup setup;

    setUp(() async => setup = await fakeBootstrap());

    testWidgets('opens new note form on New Note tap', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes));
      await tester.pumpAndSettle();

      await tester.tap(find.text('New Note'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Edit Note'), findsNothing);
    });

    testWidgets('saves note and shows it in home list', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes));
      await tester.pumpAndSettle();

      await tester.tap(find.text('New Note'));
      await tester.pumpAndSettle();

      await tester.enterText(_titleField(), 'My First Note');
      await tester.enterText(_contentField(), 'Some content here');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('My First Note'), findsOneWidget);
      expect(find.text('1 Note'), findsOneWidget);
    });

    testWidgets('cancel returns to home without saving', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes));
      await tester.pumpAndSettle();

      await tester.tap(find.text('New Note'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('0 Notes'), findsOneWidget);
      expect(find.text('No Notes Yet'), findsOneWidget);
    });
  });

  group('NoteDetail - edit', () {
    late AppTestSetup setup;

    setUp(() async {
      setup = await fakeBootstrap();
      await setup.fakeFirestore.collection('notes').add({
        'title': 'Original Title',
        'content': 'Original Content',
        'createdAt': Timestamp.fromDate(DateTime(2026, 6, 10)),
      });
    });

    testWidgets('opens pre-filled edit form with Edit Note title', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Original Title'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Note'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.trash), findsOneWidget);

      final titleField = tester.widget<CupertinoTextField>(_titleField());
      expect(titleField.controller?.text, 'Original Title');
    });

    testWidgets('saves edited title and shows update in list', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Original Title'));
      await tester.pumpAndSettle();

      await tester.enterText(_titleField(), 'Updated Title');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Updated Title'), findsOneWidget);
      expect(find.text('Original Title'), findsNothing);
    });
  });

  group('NoteDetail - delete', () {
    late AppTestSetup setup;

    setUp(() async {
      setup = await fakeBootstrap();
      await setup.fakeFirestore.collection('notes').add({
        'title': 'Note to Delete',
        'content': 'Will be removed',
        'createdAt': Timestamp.fromDate(DateTime(2026, 6, 10)),
      });
    });

    testWidgets('shows confirmation dialog on delete tap', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Note to Delete'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(CupertinoIcons.trash));
      await tester.pumpAndSettle();

      expect(find.text('Delete Note'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this note?'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('removes note from list after confirming delete', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Note to Delete'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(CupertinoIcons.trash));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Note to Delete'), findsNothing);
      expect(find.text('0 Notes'), findsOneWidget);
      expect(find.text('No Notes Yet'), findsOneWidget);
    });
  });
}
