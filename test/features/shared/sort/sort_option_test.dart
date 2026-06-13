import 'package:flutter_test/flutter_test.dart';
import 'package:inotes/features/shared/sort/sort_option.dart';

void main() {
  group('SortOption', () {
    test('two instances with same field and direction are equal', () {
      const a = SortOption(field: SortField.createdAt, direction: SortDirection.desc);
      const b = SortOption(field: SortField.createdAt, direction: SortDirection.desc);
      expect(a, equals(b));
    });

    test('instances with different field are not equal', () {
      const a = SortOption(field: SortField.createdAt, direction: SortDirection.desc);
      const b = SortOption(field: SortField.title, direction: SortDirection.desc);
      expect(a, isNot(equals(b)));
    });

    test('instances with different direction are not equal', () {
      const a = SortOption(field: SortField.title, direction: SortDirection.asc);
      const b = SortOption(field: SortField.title, direction: SortDirection.desc);
      expect(a, isNot(equals(b)));
    });

    test('covers all SortField values', () {
      expect(SortField.values, containsAll([SortField.createdAt, SortField.updatedAt, SortField.title]));
    });

    test('covers all SortDirection values', () {
      expect(SortDirection.values, containsAll([SortDirection.asc, SortDirection.desc]));
    });
  });
}
