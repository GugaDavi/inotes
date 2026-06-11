import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/auth/domain/entities/session_entity.dart';
import 'package:inotes/features/auth/domain/repositories/session_repository.dart';

class StartSessionUseCase {
  const StartSessionUseCase(this._repository);

  final SessionRepository _repository;

  Future<Result<SessionEntity>> execute({String? code}) => _repository.startSession(code: code);
}
