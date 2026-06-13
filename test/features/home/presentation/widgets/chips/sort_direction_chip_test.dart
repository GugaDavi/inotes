import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/features/home/presentation/widgets/chips/sort_direction_chip.dart';

Widget build({IconData icon = CupertinoIcons.arrow_up, bool isSelected = false, VoidCallback? onTap}) {
  return CupertinoApp(
    home: SortDirectionChip(icon: icon, isSelected: isSelected, onTap: onTap ?? () {}),
  );
}

void main() {
  group('SortDirectionChip', () {
    testWidgets('renders the given icon', (tester) async {
      await tester.pumpWidget(build(icon: CupertinoIcons.arrow_up));
      expect(find.byIcon(CupertinoIcons.arrow_up), findsOneWidget);
    });

    testWidgets('renders in unselected state without error', (tester) async {
      await tester.pumpWidget(build(isSelected: false));
      expect(find.byType(SortDirectionChip), findsOneWidget);
    });

    testWidgets('renders in selected state without error', (tester) async {
      await tester.pumpWidget(build(isSelected: true));
      expect(find.byType(SortDirectionChip), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(build(onTap: () => tapped = true));
      await tester.tap(find.byType(SortDirectionChip));
      expect(tapped, isTrue);
    });
  });
}
