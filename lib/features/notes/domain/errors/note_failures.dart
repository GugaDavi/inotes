import 'package:inotes/core/errors/failures.dart';

class EmptyTitleFailure extends AppFailure {
  const EmptyTitleFailure();

  @override
  List<Object?> get props => [];
}

class NoteNotFoundFailure extends AppFailure {
  const NoteNotFoundFailure();

  @override
  List<Object?> get props => [];
}

class NoteFirestoreFailure extends AppFailure {
  const NoteFirestoreFailure([this.message]);

  final String? message;

  @override
  List<Object?> get props => [message];
}
