import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/features/shared/widgets/date_mask_formatter.dart';

TextEditingValue format(String newText, {String oldText = ''}) {
  return DateMaskFormatter().formatEditUpdate(
    TextEditingValue(text: oldText),
    TextEditingValue(text: newText),
  );
}

void main() {
  group('DateMaskFormatter', () {
    test('empty input produces empty output', () {
      expect(format('').text, '');
    });

    test('two digits — no slash yet', () {
      expect(format('01').text, '01');
    });

    test('adds first slash after month digits', () {
      expect(format('011').text, '01/1');
    });

    test('adds second slash after day digits', () {
      expect(format('01012').text, '01/01/2');
    });

    test('full 8-digit date formatted correctly', () {
      expect(format('01012026').text, '01/01/2026');
    });

    test('stops at 8 significant digits', () {
      expect(format('0101202699').text, '01/01/2026');
    });

    test('strips non-digit characters from input', () {
      expect(format('01/01/2026').text, '01/01/2026');
    });

    test('cursor placed at end of formatted text', () {
      final result = format('01012026');
      expect(result.selection.baseOffset, 10);
      expect(result.selection.extentOffset, 10);
    });
  });
}
