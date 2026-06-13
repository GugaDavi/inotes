import 'package:equatable/equatable.dart';

enum SortField { createdAt, updatedAt, title }

enum SortDirection { asc, desc }

class SortOption extends Equatable {
  const SortOption({required this.field, required this.direction});

  final SortField field;
  final SortDirection direction;

  @override
  List<Object?> get props => [field, direction];
}
