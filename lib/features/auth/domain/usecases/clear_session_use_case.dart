import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/auth/domain/repositories/session_repository.dart';

class ClearSessionUseCase {
  const ClearSessionUseCase(this._repository);

  final SessionRepository _repository;

  Future<Result<void>> execute() => _repository.clearSession();
}
