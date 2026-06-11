import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/features/shared/widgets/buttons/primary_button.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('renders the label', (tester) async {
      await tester.pumpWidget(const CupertinoApp(home: PrimaryButton(label: 'New Note', onPressed: null)));

      expect(find.text('New Note'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var called = false;

      await tester.pumpWidget(
        CupertinoApp(
          home: PrimaryButton(label: 'New Note', onPressed: () => called = true),
        ),
      );

      await tester.tap(find.byType(PrimaryButton));

      expect(called, isTrue);
    });

    testWidgets('does not call onPressed when disabled', (tester) async {
      var called = false;

      await tester.pumpWidget(CupertinoApp(home: PrimaryButton(label: 'New Note', onPressed: null)));

      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);

      expect(called, isFalse);
    });
  });
}
