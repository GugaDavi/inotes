import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/core/app.dart';

import '../helpers/fake_app_bootstrap.dart';

// Must exceed the 300ms debounce so the timer fires.
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
      await tester.enterText(find.byType(CupertinoSearchTextField), query);
      await tester.pump(_searchSettle);
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

  group('HomePage - filter bar', () {
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

    // The filter overlay can exceed the default 800×600 test surface when the
    // direction-chip row is visible. Each test that opens the overlay sets a
    // taller surface and resets it afterwards.
    void useTallSurface(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    Future<void> applySort(WidgetTester tester, String fieldLabel) async {
      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(fieldLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
    }

    testWidgets('filter button is not active before any filter is applied', (tester) async {
      await tester.pumpWidget(App(authNotifier: setup.notifier, routes: setup.routes));
      await tester.pumpAndSettle();

      final activeButton = find.byWidgetPredicate(
        (w) => w is Container && (w.decoration as BoxDecoration?)?.color == CupertinoColors.activeBlue,
      );
      expect(activeButton, findsNothing);
    });

    testWidgets('filter button becomes active when sort option is applied', (tester) async {
      useTallSurface(tester);
      await tester.pumpWidget(App(authNotifier: setup.notifier, routes: setup.routes));
      await tester.pumpAndSettle();

      await applySort(tester, 'Title');

      final activeButton = find.byWidgetPredicate(
        (w) => w is Container && (w.decoration as BoxDecoration?)?.color == CupertinoColors.activeBlue,
      );
      expect(activeButton, findsOneWidget);
    });

    testWidgets('sort chip appears in filter bar after sort is applied', (tester) async {
      useTallSurface(tester);
      await tester.pumpWidget(App(authNotifier: setup.notifier, routes: setup.routes));
      await tester.pumpAndSettle();

      await applySort(tester, 'Title');

      // Overlay is closed; "Title" now appears only in the filter bar sort chip.
      expect(find.text('Filters'), findsNothing);
      expect(find.text('Title'), findsOneWidget);
    });

    testWidgets('filter button becomes inactive after sort chip is cleared', (tester) async {
      useTallSurface(tester);
      await tester.pumpWidget(App(authNotifier: setup.notifier, routes: setup.routes));
      await tester.pumpAndSettle();

      await applySort(tester, 'Title');

      // Clear the sort chip via its ✕ icon
      await tester.tap(find.byIcon(CupertinoIcons.xmark_circle_fill).first);
      await tester.pumpAndSettle();

      final activeButton = find.byWidgetPredicate(
        (w) => w is Container && (w.decoration as BoxDecoration?)?.color == CupertinoColors.activeBlue,
      );
      expect(activeButton, findsNothing);
    });
  });
}
