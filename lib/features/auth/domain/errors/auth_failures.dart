import 'package:inotes/core/errors/failures.dart';

class SessionNotFoundFailure extends AppFailure {
  const SessionNotFoundFailure();

  @override
  List<Object?> get props => [];
}

class SessionStorageFailure extends AppFailure {
  const SessionStorageFailure();

  @override
  List<Object?> get props => [];
}
