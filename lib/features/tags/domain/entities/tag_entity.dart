import 'package:equatable/equatable.dart';

class TagEntity extends Equatable {
  const TagEntity({required this.id, required this.label, required this.color});

  final String id;
  final String label;
  final int color;

  @override
  List<Object?> get props => [id, label, color];
}
