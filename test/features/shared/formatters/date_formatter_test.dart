import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/features/shared/formatters/date_formatter.dart';

void main() {
  // Reference: June 10, 2026 15:30 (Wednesday)
  final reference = DateTime(2026, 6, 10, 15, 30);
  final formatter = DateFormatter();

  group('DateFormatter.formatNoteDate', () {
    group('today (diff == 0)', () {
      test('returns HH:mm', () {
        final date = DateTime(2026, 6, 10, 15, 30);
        expect(formatter.formatNoteDate(date, now: reference), '15:30');
      });

      test('pads single-digit hours and minutes', () {
        final date = DateTime(2026, 6, 10, 9, 5);
        expect(formatter.formatNoteDate(date, now: reference), '09:05');
      });
    });

    test('yesterday (diff == 1) returns Yesterday', () {
      final date = DateTime(2026, 6, 9);
      expect(formatter.formatNoteDate(date, now: reference), 'Yesterday');
    });

    group('within the week (2 <= diff < 7)', () {
      test('2 days ago returns weekday abbreviation', () {
        final date = DateTime(2026, 6, 8); // Monday
        expect(formatter.formatNoteDate(date, now: reference), 'Mon');
      });

      test('6 days ago still returns weekday abbreviation', () {
        final date = DateTime(2026, 6, 4); // Thursday
        expect(formatter.formatNoteDate(date, now: reference), 'Thu');
      });
    });

    group('older (diff >= 7)', () {
      test('7 days ago returns M/D/YYYY', () {
        final date = DateTime(2026, 6, 3);
        expect(formatter.formatNoteDate(date, now: reference), '6/3/2026');
      });

      test('old date returns M/D/YYYY without zero-padding', () {
        final date = DateTime(2020, 1, 1);
        expect(formatter.formatNoteDate(date, now: reference), '1/1/2020');
      });
    });
  });
}
