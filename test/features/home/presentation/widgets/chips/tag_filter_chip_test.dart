import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/features/home/presentation/widgets/chips/tag_filter_chip.dart';
import 'package:inotes/features/tags/domain/entities/tag_entity.dart';

const _tag = TagEntity(id: 'tag-work', label: 'Work', color: 0xFF0000FF);

Widget build({bool isSelected = false, VoidCallback? onTap}) {
  return CupertinoApp(
    home: TagFilterChip(tag: _tag, isSelected: isSelected, onTap: onTap ?? () {}),
  );
}

void main() {
  group('TagFilterChip', () {
    testWidgets('renders tag label', (tester) async {
      await tester.pumpWidget(build());
      expect(find.text('Work'), findsOneWidget);
    });

    testWidgets('renders in unselected state without error', (tester) async {
      await tester.pumpWidget(build(isSelected: false));
      expect(find.byType(TagFilterChip), findsOneWidget);
    });

    testWidgets('renders in selected state without error', (tester) async {
      await tester.pumpWidget(build(isSelected: true));
      expect(find.byType(TagFilterChip), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(build(onTap: () => tapped = true));
      await tester.tap(find.byType(TagFilterChip));
      expect(tapped, isTrue);
    });
  });
}
