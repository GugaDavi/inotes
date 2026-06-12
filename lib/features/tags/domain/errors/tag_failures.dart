import 'package:inotes/core/errors/failures.dart';

class TagFirestoreFailure extends AppFailure {
  const TagFirestoreFailure([this.message]);

  final String? message;

  @override
  List<Object?> get props => [message];
}
