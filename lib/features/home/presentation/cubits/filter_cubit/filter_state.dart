import 'package:equatable/equatable.dart';
import 'package:inotes/features/home/domain/entities/filter_options_entity.dart';

class FilterState extends Equatable {
  const FilterState({this.options});

  final FilterOptionsEntity? options;

  bool get isActive => options?.dateFilter != null || options?.tagFilter.isNotEmpty == true;

  @override
  List<Object?> get props => [options];
}
