import 'package:equatable/equatable.dart';
import 'package:inotes/features/shared/filter/date_range_filter.dart';

class FilterOptionsEntity extends Equatable {
  const FilterOptionsEntity({this.dateFilter, this.tagFilter = const []});

  final DateRangeFilter? dateFilter;
  final List<String> tagFilter;

  @override
  List<Object?> get props => [dateFilter, tagFilter];
}
