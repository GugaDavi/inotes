import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/core/app.dart';

import '../helpers/fake_app_bootstrap.dart';

void main() {
  group('HomePage - empty state', () {
    late AppTestSetup setup;

    setUpAll(() async {
      setup = await fakeBootstrap();
    });

    testWidgets('shows app title', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes));
      await tester.pumpAndSettle();

      expect(find.text('iNotes'), findsOneWidget);
    });

    testWidgets('shows new note button', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes));
      await tester.pumpAndSettle();

      expect(find.text('New Note'), findsOneWidget);
    });

    testWidgets('shows search field', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoSearchTextField), findsOneWidget);
    });

    testWidgets('shows empty state when there are no notes', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes));
      await tester.pumpAndSettle();

      expect(find.text('No Notes Yet'), findsOneWidget);
      expect(find.text('Tap the icon to write your first note.'), findsOneWidget);
    });

    testWidgets('shows 0 Notes in bottom bar', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes));
      await tester.pumpAndSettle();

      expect(find.text('0 Notes'), findsOneWidget);
    });
  });

  group('HomePage - with notes', () {
    late AppTestSetup setup;

    setUpAll(() async {
      setup = await fakeBootstrap();
      await setup.fakeFirestore.collection('notes').add({
        'title': 'Shopping List',
        'content': 'Milk, eggs, bread',
        'createdAt': Timestamp.fromDate(DateTime(2026, 6, 10)),
      });
      await setup.fakeFirestore.collection('notes').add({
        'title': 'Meeting Notes',
        'content': 'Discuss roadmap',
        'createdAt': Timestamp.fromDate(DateTime(2026, 6, 9)),
      });
    });

    testWidgets('shows note titles in list', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes));
      await tester.pumpAndSettle();

      expect(find.text('Shopping List'), findsOneWidget);
      expect(find.text('Meeting Notes'), findsOneWidget);
    });

    testWidgets('shows note content preview in list', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes));
      await tester.pumpAndSettle();

      expect(find.text('Milk, eggs, bread'), findsOneWidget);
      expect(find.text('Discuss roadmap'), findsOneWidget);
    });

    testWidgets('shows correct note count in bottom bar', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes));
      await tester.pumpAndSettle();

      expect(find.text('2 Notes'), findsOneWidget);
    });

    testWidgets('does not show empty state', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes));
      await tester.pumpAndSettle();

      expect(find.text('No Notes Yet'), findsNothing);
    });
  });
}
