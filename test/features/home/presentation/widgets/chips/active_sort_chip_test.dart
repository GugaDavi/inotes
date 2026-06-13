import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/features/home/presentation/widgets/chips/active_sort_chip.dart';
import 'package:inotes/features/shared/sort/sort_option.dart';

Widget build({
  SortOption sort = const SortOption(field: SortField.title, direction: SortDirection.asc),
  VoidCallback? onClear,
}) {
  return CupertinoApp(
    home: ActiveSortChip(sort: sort, onClear: onClear ?? () {}),
  );
}

void main() {
  group('ActiveSortChip — field label', () {
    testWidgets('shows "Created" for SortField.createdAt', (tester) async {
      await tester.pumpWidget(
        build(sort: const SortOption(field: SortField.createdAt, direction: SortDirection.asc)),
      );
      expect(find.text('Created'), findsOneWidget);
    });

    testWidgets('shows "Updated" for SortField.updatedAt', (tester) async {
      await tester.pumpWidget(
        build(sort: const SortOption(field: SortField.updatedAt, direction: SortDirection.asc)),
      );
      expect(find.text('Updated'), findsOneWidget);
    });

    testWidgets('shows "Title" for SortField.title', (tester) async {
      await tester.pumpWidget(
        build(sort: const SortOption(field: SortField.title, direction: SortDirection.asc)),
      );
      expect(find.text('Title'), findsOneWidget);
    });
  });

  group('ActiveSortChip — direction icon', () {
    testWidgets('shows arrow_up for SortDirection.asc', (tester) async {
      await tester.pumpWidget(
        build(sort: const SortOption(field: SortField.title, direction: SortDirection.asc)),
      );
      expect(find.byIcon(CupertinoIcons.arrow_up), findsOneWidget);
    });

    testWidgets('shows arrow_down for SortDirection.desc', (tester) async {
      await tester.pumpWidget(
        build(sort: const SortOption(field: SortField.title, direction: SortDirection.desc)),
      );
      expect(find.byIcon(CupertinoIcons.arrow_down), findsOneWidget);
    });
  });

  group('ActiveSortChip — interaction', () {
    testWidgets('calls onClear when xmark icon tapped', (tester) async {
      var cleared = false;
      await tester.pumpWidget(build(onClear: () => cleared = true));
      await tester.tap(find.byIcon(CupertinoIcons.xmark_circle_fill));
      expect(cleared, isTrue);
    });
  });
}
