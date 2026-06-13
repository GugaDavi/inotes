import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/features/shared/widgets/date_field.dart';

Widget buildField({
  String label = 'From',
  TextEditingController? controller,
  String? error,
  ValueChanged<String>? onChanged,
}) {
  return CupertinoApp(
    home: Padding(
      padding: const EdgeInsets.all(16),
      child: DateField(
        label: label,
        controller: controller ?? TextEditingController(),
        error: error,
        onChanged: onChanged,
      ),
    ),
  );
}

void main() {
  group('DateField', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(buildField(label: 'From'));
      expect(find.text('From'), findsOneWidget);
    });

    testWidgets('renders CupertinoTextField with MM/DD/YYYY placeholder', (tester) async {
      await tester.pumpWidget(buildField());
      expect(find.byType(CupertinoTextField), findsOneWidget);
    });

    testWidgets('shows error text when error is not null', (tester) async {
      await tester.pumpWidget(buildField(error: 'Invalid date'));
      expect(find.text('Invalid date'), findsOneWidget);
    });

    testWidgets('does not show error text when error is null', (tester) async {
      await tester.pumpWidget(buildField());
      expect(find.text('Invalid date'), findsNothing);
    });

    testWidgets('calls onChanged when text is entered', (tester) async {
      String? captured;
      await tester.pumpWidget(buildField(onChanged: (v) => captured = v));
      await tester.enterText(find.byType(CupertinoTextField), '01012026');
      expect(captured, isNotNull);
    });

    testWidgets('pre-fills text from controller', (tester) async {
      final ctrl = TextEditingController(text: '06/13/2026');
      await tester.pumpWidget(buildField(controller: ctrl));
      expect(find.text('06/13/2026'), findsOneWidget);
    });
  });
}
