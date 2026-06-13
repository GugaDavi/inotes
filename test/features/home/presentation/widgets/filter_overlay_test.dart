import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/features/home/presentation/widgets/filter_overlay.dart';
import 'package:inotes/features/shared/filter/date_range_filter.dart';
import 'package:inotes/features/shared/sort/sort_option.dart';
import 'package:inotes/features/tags/domain/entities/tag_entity.dart';

const _tagWork = TagEntity(id: 'tag-work', label: 'Work', color: 0xFF0000FF);
const _tagPersonal = TagEntity(id: 'tag-personal', label: 'Personal', color: 0xFF00FF00);

// Wraps FilterOverlay (with CompositedTransformFollower) — used only for
// structural/dismiss tests where we never need to tap Apply.
Widget buildOverlay({
  DateRangeFilter? initialDate,
  List<String> initialTagIds = const [],
  SortOption? initialSort,
  List<TagEntity> availableTags = const [],
  void Function(DateRangeFilter?, List<String>, SortOption?)? onApply,
  VoidCallback? onDismiss,
}) {
  final link = LayerLink();
  return CupertinoApp(
    home: Stack(
      children: [
        CompositedTransformTarget(link: link, child: const SizedBox(width: 100, height: 40)),
        FilterOverlay(
          layerLink: link,
          initialDate: initialDate,
          initialTagIds: initialTagIds,
          initialSort: initialSort,
          availableTags: availableTags,
          onApply: onApply ?? (_, _, _) {},
          onDismiss: onDismiss ?? () {},
        ),
      ],
    ),
  );
}

// Wraps FilterOverlayContent directly — no CompositedTransformFollower, so
// tap interactions (Apply, field chips, tag chips) work correctly in tests.
Widget buildContent({
  DateRangeFilter? initialDate,
  List<String> initialTagIds = const [],
  SortOption? initialSort,
  List<TagEntity> availableTags = const [],
  void Function(DateRangeFilter?, List<String>, SortOption?)? onApply,
  VoidCallback? onDismiss,
}) {
  return CupertinoApp(
    home: SizedBox(
      width: 320,
      child: FilterOverlayContent(
        initialDate: initialDate,
        initialTagIds: initialTagIds,
        initialSort: initialSort,
        availableTags: availableTags,
        onApply: onApply ?? (_, _, _) {},
        onDismiss: onDismiss ?? () {},
      ),
    ),
  );
}

void main() {
  group('FilterOverlay — structure', () {
    testWidgets('renders Filters header', (tester) async {
      await tester.pumpWidget(buildOverlay());
      expect(find.text('Filters'), findsOneWidget);
    });

    testWidgets('renders SORT BY section with field chips', (tester) async {
      await tester.pumpWidget(buildOverlay());
      expect(find.text('SORT BY'), findsOneWidget);
      expect(find.text('Created'), findsOneWidget);
      expect(find.text('Updated'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
    });

    testWidgets('renders DATE section', (tester) async {
      await tester.pumpWidget(buildOverlay());
      expect(find.text('DATE'), findsOneWidget);
    });

    testWidgets('does not show TAGS section when availableTags is empty', (tester) async {
      await tester.pumpWidget(buildOverlay(availableTags: []));
      expect(find.text('TAGS'), findsNothing);
    });

    testWidgets('shows TAGS section when availableTags is not empty', (tester) async {
      await tester.pumpWidget(buildOverlay(availableTags: [_tagWork]));
      expect(find.text('TAGS'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
    });
  });

  group('FilterOverlay — dismiss', () {
    testWidgets('calls onDismiss when close button tapped', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(buildOverlay(onDismiss: () => dismissed = true));
      await tester.tap(find.byIcon(CupertinoIcons.xmark_circle_fill));
      expect(dismissed, isTrue);
    });
  });

  // ── FilterOverlayContent — behaviour tests ─────────────────────────────────
  // These tests use FilterOverlayContent directly (no CompositedTransformFollower)
  // so that widget interactions (tap Apply, enter text) work in the test harness.

  group('FilterOverlayContent — sort', () {
    testWidgets('direction chips appear after a sort field is selected', (tester) async {
      await tester.pumpWidget(buildContent());
      expect(find.byIcon(CupertinoIcons.arrow_up), findsNothing);

      await tester.tap(find.text('Title'));
      await tester.pumpAndSettle();

      expect(find.byIcon(CupertinoIcons.arrow_up), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.arrow_down), findsOneWidget);
    });

    testWidgets('onApply called with sort option when field selected then Apply tapped', (tester) async {
      SortOption? captured;
      await tester.pumpWidget(buildContent(onApply: (_, _, sort) => captured = sort));

      await tester.tap(find.text('Title'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply'));

      expect(captured, const SortOption(field: SortField.title, direction: SortDirection.desc));
    });

    testWidgets('onApply called with null sort when no field selected', (tester) async {
      SortOption? captured = const SortOption(field: SortField.title, direction: SortDirection.asc);
      await tester.pumpWidget(buildContent(onApply: (_, _, sort) => captured = sort));

      await tester.tap(find.text('Apply'));

      expect(captured, isNull);
    });

    testWidgets('pre-populates sort field from initialSort', (tester) async {
      await tester.pumpWidget(
        buildContent(initialSort: const SortOption(field: SortField.createdAt, direction: SortDirection.asc)),
      );
      expect(find.byIcon(CupertinoIcons.arrow_up), findsOneWidget);
    });
  });

  group('FilterOverlayContent — date', () {
    testWidgets('shows validation error for invalid date', (tester) async {
      await tester.pumpWidget(buildContent());

      // '13322026' → formatter gives '13/32/2026'; month=13 and day=32 are out
      // of range, so _parse returns null and the error is shown.
      await tester.enterText(
        find.byWidgetPredicate((w) => w is CupertinoTextField && w.placeholder == 'MM/DD/YYYY').first,
        '13322026',
      );
      await tester.tap(find.text('Apply'));
      await tester.pump();

      expect(find.text('Invalid date'), findsOneWidget);
    });

    testWidgets('onApply called with DateRangeFilter when valid date entered', (tester) async {
      DateRangeFilter? captured;
      await tester.pumpWidget(buildContent(onApply: (date, _, _) => captured = date));

      await tester.enterText(
        find.byWidgetPredicate((w) => w is CupertinoTextField && w.placeholder == 'MM/DD/YYYY').first,
        '06132026',
      );
      await tester.tap(find.text('Apply'));

      expect(captured, isNotNull);
      expect(captured!.from, DateTime(2026, 6, 13));
    });

    testWidgets('pre-populates From field from initialDate', (tester) async {
      await tester.pumpWidget(buildContent(initialDate: DateRangeFilter(from: DateTime(2026, 6, 10))));
      expect(find.text('06/10/2026'), findsOneWidget);
    });
  });

  group('FilterOverlayContent — tags', () {
    testWidgets('onApply called with selected tag ids', (tester) async {
      List<String>? captured;
      await tester.pumpWidget(
        buildContent(
          availableTags: [_tagWork, _tagPersonal],
          onApply: (_, tags, _) => captured = tags,
        ),
      );

      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply'));

      expect(captured, ['tag-work']);
    });

    testWidgets('pre-populates selected tags from initialTagIds', (tester) async {
      await tester.pumpWidget(
        buildContent(availableTags: [_tagWork, _tagPersonal], initialTagIds: ['tag-work']),
      );
      expect(find.text('Work'), findsOneWidget);
    });
  });
}
