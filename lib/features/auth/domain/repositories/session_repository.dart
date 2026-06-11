import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/auth/domain/entities/session_entity.dart';

abstract interface class SessionRepository {
  Future<Result<SessionEntity>> getCurrentSession();
  Future<Result<SessionEntity>> startSession({String? code});
  Future<Result<void>> clearSession();
}
