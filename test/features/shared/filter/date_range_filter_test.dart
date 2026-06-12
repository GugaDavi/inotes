import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/features/shared/filter/date_range_filter.dart';

void main() {
  group('DateRangeFilter', () {
    group('single day (no to)', () {
      final filter = DateRangeFilter(from: _june10);

      test('matches a datetime at the start of the day', () {
        expect(filter.matches(DateTime(2026, 6, 10, 0, 0, 0)), isTrue);
      });

      test('matches a datetime in the middle of the day', () {
        expect(filter.matches(DateTime(2026, 6, 10, 14, 30)), isTrue);
      });

      test('matches a datetime at the end of the day', () {
        expect(filter.matches(DateTime(2026, 6, 10, 23, 59, 59)), isTrue);
      });

      test('does not match the day before', () {
        expect(filter.matches(DateTime(2026, 6, 9, 23, 59, 59)), isFalse);
      });

      test('does not match the day after', () {
        expect(filter.matches(DateTime(2026, 6, 11, 0, 0, 0)), isFalse);
      });
    });

    group('date range (with to)', () {
      final filter = DateRangeFilter(from: _june10, to: _june12);

      test('matches the first day', () {
        expect(filter.matches(DateTime(2026, 6, 10, 0, 0, 0)), isTrue);
      });

      test('matches a day in the middle of the range', () {
        expect(filter.matches(DateTime(2026, 6, 11, 12, 0)), isTrue);
      });

      test('matches the last day', () {
        expect(filter.matches(DateTime(2026, 6, 12, 23, 59, 59)), isTrue);
      });

      test('does not match the day before the range', () {
        expect(filter.matches(DateTime(2026, 6, 9, 23, 59, 59)), isFalse);
      });

      test('does not match the day after the range', () {
        expect(filter.matches(DateTime(2026, 6, 13, 0, 0, 0)), isFalse);
      });
    });

    group('equality', () {
      test('two filters with same from and no to are equal', () {
        expect(DateRangeFilter(from: _june10), DateRangeFilter(from: _june10));
      });

      test('two filters with same from and to are equal', () {
        expect(DateRangeFilter(from: _june10, to: _june12), DateRangeFilter(from: _june10, to: _june12));
      });

      test('filters with different from are not equal', () {
        expect(DateRangeFilter(from: _june10), isNot(DateRangeFilter(from: _june12)));
      });
    });
  });
}

final _june10 = DateTime(2026, 6, 10);
final _june12 = DateTime(2026, 6, 12);
