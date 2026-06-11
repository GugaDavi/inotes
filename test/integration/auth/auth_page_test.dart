import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/core/app.dart';

import '../helpers/fake_app_bootstrap.dart';

Finder _codeField() => find.byWidgetPredicate((w) => w is CupertinoTextField && w.placeholder == 'Enter your code…');

void main() {
  group('AuthPage - form', () {
    late AppTestSetup setup;

    setUpAll(() async => setup = await fakeBootstrap());

    testWidgets('shows Session Code label', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes, initialRoute: '/auth'));
      await tester.pumpAndSettle();

      expect(find.text('Session Code'), findsOneWidget);
    });

    testWidgets('shows code input field', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes, initialRoute: '/auth'));
      await tester.pumpAndSettle();

      expect(_codeField(), findsOneWidget);
    });

    testWidgets('shows Enter and Start New Session buttons', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes, initialRoute: '/auth'));
      await tester.pumpAndSettle();

      expect(find.text('Enter'), findsOneWidget);
      expect(find.text('Start New Session'), findsOneWidget);
    });

    testWidgets('shows error when submitting empty code', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes, initialRoute: '/auth'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enter'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a session code.'), findsOneWidget);
    });
  });

  group('AuthPage - enter existing code', () {
    late AppTestSetup setup;

    setUp(() async => setup = await fakeBootstrap());

    testWidgets('navigates away from auth after entering a valid code', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes, initialRoute: '/auth'));
      await tester.pumpAndSettle();

      await tester.enterText(_codeField(), testSessionCode);
      await tester.tap(find.text('Enter'));
      await tester.pumpAndSettle();

      expect(find.text('Session Code'), findsNothing);
      expect(find.text('Enter'), findsNothing);
    });
  });

  group('AuthPage - new session', () {
    late AppTestSetup setup;

    setUp(() async => setup = await fakeBootstrap());

    testWidgets('shows generated code after tapping Start New Session', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes, initialRoute: '/auth'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start New Session'));
      await tester.pumpAndSettle();

      expect(find.text('Your Session Code'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('navigates away from auth after confirming new session', (tester) async {
      await tester.pumpWidget(App(routes: setup.routes, initialRoute: '/auth'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start New Session'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Your Session Code'), findsNothing);
      expect(find.text('Continue'), findsNothing);
    });
  });
}
