import 'package:equatable/equatable.dart';

class DateRangeFilter extends Equatable {
  const DateRangeFilter({required this.from, this.to});

  final DateTime from;

  /// Inclusive upper bound. When null, the filter matches only [from]'s calendar day.
  final DateTime? to;

  bool matches(DateTime date) {
    final start = DateTime(from.year, from.month, from.day);
    final endDay = to ?? from;
    final end = DateTime(endDay.year, endDay.month, endDay.day, 23, 59, 59, 999);
    return !date.isBefore(start) && !date.isAfter(end);
  }

  @override
  List<Object?> get props => [from, to];
}
