import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/features/home/presentation/widgets/chips/sort_field_chip.dart';

Widget build({String label = 'Title', bool isSelected = false, VoidCallback? onTap}) {
  return CupertinoApp(
    home: SortFieldChip(label: label, isSelected: isSelected, onTap: onTap ?? () {}),
  );
}

void main() {
  group('SortFieldChip', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(build(label: 'Created'));
      expect(find.text('Created'), findsOneWidget);
    });

    testWidgets('renders in unselected state without error', (tester) async {
      await tester.pumpWidget(build(isSelected: false));
      expect(find.byType(SortFieldChip), findsOneWidget);
    });

    testWidgets('renders in selected state without error', (tester) async {
      await tester.pumpWidget(build(isSelected: true));
      expect(find.byType(SortFieldChip), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(build(onTap: () => tapped = true));
      await tester.tap(find.byType(SortFieldChip));
      expect(tapped, isTrue);
    });
  });
}
