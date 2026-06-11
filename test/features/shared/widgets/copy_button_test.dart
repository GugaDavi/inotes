import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/features/shared/widgets/buttons/copy_button.dart';

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => null,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
  });

  Widget wrap(Widget child) => CupertinoApp(
    home: CupertinoPageScaffold(child: Center(child: child)),
  );

  group('CopyButton', () {
    testWidgets('shows copy icon initially', (tester) async {
      await tester.pumpWidget(wrap(const CopyButton(text: 'ABCD1234')));

      expect(find.byIcon(CupertinoIcons.doc_on_doc), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.checkmark_circle), findsNothing);
    });

    testWidgets('shows checkmark icon after tap', (tester) async {
      await tester.pumpWidget(wrap(const CopyButton(text: 'ABCD1234')));

      await tester.tap(find.byType(CopyButton));
      await tester.pump();

      expect(find.byIcon(CupertinoIcons.checkmark_circle), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.doc_on_doc), findsNothing);

      // drain the pending 2s timer so the widget can be disposed cleanly
      await tester.pump(const Duration(seconds: 2, milliseconds: 1));
      await tester.pump();
    });

    testWidgets('returns to copy icon after 2 seconds', (tester) async {
      await tester.pumpWidget(wrap(const CopyButton(text: 'ABCD1234')));

      await tester.tap(find.byType(CopyButton));
      await tester.pump();
      expect(find.byIcon(CupertinoIcons.checkmark_circle), findsOneWidget);

      await tester.pump(const Duration(seconds: 2, milliseconds: 1));
      await tester.pump();
      expect(find.byIcon(CupertinoIcons.doc_on_doc), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.checkmark_circle), findsNothing);
    });
  });
}
