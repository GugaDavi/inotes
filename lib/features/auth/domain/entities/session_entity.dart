import 'package:equatable/equatable.dart';

class SessionEntity extends Equatable {
  const SessionEntity({required this.code});

  final String code;

  @override
  List<Object?> get props => [code];
}
