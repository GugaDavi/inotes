import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/core/app.dart';

import '../helpers/fake_app_bootstrap.dart';

// Must exceed the 300ms debounce so the timer fires and the isolate completes.
const _searchSettle = Duration(milliseconds: 400);

void main() {
  group('HomePage - empty state', () {
    late AppTestSetup setup;

    setUpAll(() async {
      setup = await fakeBootstrap();
    });

    testWidgets('shows app title', (tester) async {
      await tester.pumpWidget(App(authNotifier: setup.notifier, routes: setup.routes));
      await tester.pumpAndSettle();

      expect(find.text('iNotes'), findsOneWidget);
    });

    testWidgets('shows new note button', (tester) async {
      await tester.pumpWidget(App(authNotifier: setup.notifier, routes: setup.routes));
      await tester.pumpAndSettle();

      expect(find.text('New Note'), findsOneWidget);
    });

    testWidgets('shows search field', (tester) async {
      await tester.pumpWidget(App(authNotifier: setup.notifier, routes: setup.routes));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoSearchTextField), findsOneWidget);
    });

    testWidgets('shows empty state when there are no notes', (tester) async {
      await tester.pumpWidget(App(authNotifier: setup.notifier, routes: setup.routes));
      await tester.pumpAndSettle();

      expect(find.text('No Notes Yet'), findsOneWidget);
      expect(find.text('Tap the icon to write your first note.'), findsOneWidget);
    });

    testWidgets('shows 0 Notes in bottom bar', (tester) async {
      await tester.pumpWidget(App(authNotifier: setup.notifier, routes: setup.routes));
      await tester.pumpAndSettle();

      expect(find.text('0 Notes'), findsOneWidget);
    });
  });

  group('HomePage - with notes', () {
    late AppTestSetup setup;

    setUpAll(() async {
      setup = await fakeBootstrap();
      await setup.fakeFirestore.seedNote(
        title: 'Shopping List',
        content: 'Milk, eggs, bread',
        createdAt: DateTime(2026, 6, 10),
      );
      await setup.fakeFirestore.seedNote(
        title: 'Meeting Notes',
        content: 'Discuss roadmap',
        createdAt: DateTime(2026, 6, 9),
      );
    });

    testWidgets('shows note titles in list', (tester) async {
      await tester.pumpWidget(App(authNotifier: setup.notifier, routes: setup.routes));
      await tester.pumpAndSettle();

      expect(find.text('Shopping List'), findsOneWidget);
      expect(find.text('Meeting Notes'), findsOneWidget);
    });

    testWidgets('shows note content preview in list', (tester) async {
      await tester.pumpWidget(App(authNotifier: setup.notifier, routes: setup.routes));
      await tester.pumpAndSettle();

      expect(find.text('Milk, eggs, bread'), findsOneWidget);
      expect(find.text('Discuss roadmap'), findsOneWidget);
    });

    testWidgets('shows correct note count in bottom bar', (tester) async {
      await tester.pumpWidget(App(authNotifier: setup.notifier, routes: setup.routes));
      await tester.pumpAndSettle();

      expect(find.text('2 Notes'), findsOneWidget);
    });

    testWidgets('does not show empty state', (tester) async {
      await tester.pumpWidget(App(authNotifier: setup.notifier, routes: setup.routes));
      await tester.pumpAndSettle();

      expect(find.text('No Notes Yet'), findsNothing);
    });
  });

  group('HomePage - search', () {
    late AppTestSetup setup;

    setUpAll(() async {
      setup = await fakeBootstrap();
      await setup.fakeFirestore.seedNote(
        title: 'Shopping List',
        content: 'Milk, eggs, bread',
        createdAt: DateTime(2026, 6, 10),
      );
      await setup.fakeFirestore.seedNote(
        title: 'Meeting Notes',
        content: 'Discuss roadmap for Q3',
        createdAt: DateTime(2026, 6, 9),
      );
    });

    Future<void> search(WidgetTester tester, String query) async {
      await tester.runAsync(() async {
        await tester.enterText(find.byType(CupertinoSearchTextField), query);
        await Future.delayed(_searchSettle);
        FocusManager.instance.primaryFocus?.unfocus();
      });
      await tester.pumpAndSettle();
    }

    testWidgets('filters notes by title match', (tester) async {
      await tester.pumpWidget(App(authNotifier: setup.notifier, routes: setup.routes));
      await tester.pumpAndSettle();

      await search(tester, 'Shopping');

      expect(find.text('Shopping List'), findsOneWidget);
      expect(find.text('Meeting Notes'), findsNothing);
    });

    testWidgets('filters notes by content match', (tester) async {
      await tester.pumpWidget(App(authNotifier: setup.notifier, routes: setup.routes));
      await tester.pumpAndSettle();

      await search(tester, 'roadmap');

      expect(find.text('Meeting Notes'), findsOneWidget);
      expect(find.text('Shopping List'), findsNothing);
    });

    testWidgets('search is case-insensitive', (tester) async {
      await tester.pumpWidget(App(authNotifier: setup.notifier, routes: setup.routes));
      await tester.pumpAndSettle();

      await search(tester, 'SHOPPING');

      expect(find.text('Shopping List'), findsOneWidget);
      expect(find.text('Meeting Notes'), findsNothing);
    });

    testWidgets('hides all notes when no notes match', (tester) async {
      await tester.pumpWidget(App(authNotifier: setup.notifier, routes: setup.routes));
      await tester.pumpAndSettle();

      await search(tester, 'xyz123');

      expect(find.text('Shopping List'), findsNothing);
      expect(find.text('Meeting Notes'), findsNothing);
    });

    testWidgets('restores all notes when search is cleared', (tester) async {
      await tester.pumpWidget(App(authNotifier: setup.notifier, routes: setup.routes));
      await tester.pumpAndSettle();

      await search(tester, 'Shopping');
      expect(find.text('Shopping List'), findsOneWidget);
      expect(find.text('Meeting Notes'), findsNothing);

      await search(tester, '');
      expect(find.text('Shopping List'), findsOneWidget);
      expect(find.text('Meeting Notes'), findsOneWidget);
    });
  });
}
