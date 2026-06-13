import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/features/home/presentation/widgets/chips/active_tag_chip.dart';
import 'package:inotes/features/tags/domain/entities/tag_entity.dart';

const _tag = TagEntity(id: 'tag-work', label: 'Work', color: 0xFF0000FF);

Widget build({VoidCallback? onClear}) {
  return CupertinoApp(
    home: ActiveTagChip(tag: _tag, onClear: onClear ?? () {}),
  );
}

void main() {
  group('ActiveTagChip', () {
    testWidgets('renders tag label', (tester) async {
      await tester.pumpWidget(build());
      expect(find.text('Work'), findsOneWidget);
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
