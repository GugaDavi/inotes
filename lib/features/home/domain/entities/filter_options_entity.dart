import 'package:equatable/equatable.dart';
import 'package:inotes/features/shared/filter/date_range_filter.dart';
import 'package:inotes/features/shared/sort/sort_option.dart';

class FilterOptionsEntity extends Equatable {
  const FilterOptionsEntity({this.dateFilter, this.tagFilter = const [], this.sortOption});

  final DateRangeFilter? dateFilter;
  final List<String> tagFilter;
  final SortOption? sortOption;

  @override
  List<Object?> get props => [dateFilter, tagFilter, sortOption];
}
