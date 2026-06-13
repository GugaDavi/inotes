import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/features/home/presentation/widgets/chips/active_filter_chip.dart';

Widget build({String label = 'Test', VoidCallback? onClear}) {
  return CupertinoApp(
    home: ActiveFilterChip(label: label, onClear: onClear ?? () {}),
  );
}

void main() {
  group('ActiveFilterChip', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(build(label: '6/10/2026'));
      expect(find.text('6/10/2026'), findsOneWidget);
    });

    testWidgets('renders clear icon', (tester) async {
      await tester.pumpWidget(build());
      expect(find.byIcon(CupertinoIcons.xmark_circle_fill), findsOneWidget);
    });

    testWidgets('calls onClear when icon tapped', (tester) async {
      var cleared = false;
      await tester.pumpWidget(build(onClear: () => cleared = true));
      await tester.tap(find.byIcon(CupertinoIcons.xmark_circle_fill));
      expect(cleared, isTrue);
    });
  });
}
