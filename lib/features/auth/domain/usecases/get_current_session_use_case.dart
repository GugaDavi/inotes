import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/auth/domain/entities/session_entity.dart';
import 'package:inotes/features/auth/domain/repositories/session_repository.dart';

class GetCurrentSessionUseCase {
  const GetCurrentSessionUseCase(this._repository);

  final SessionRepository _repository;

  Future<Result<SessionEntity>> execute() => _repository.getCurrentSession();
}
