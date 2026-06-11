import 'dart:math';

import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/auth/domain/entities/session_entity.dart';
import 'package:inotes/features/auth/domain/errors/auth_failures.dart';
import 'package:inotes/features/auth/domain/repositories/session_repository.dart';
import 'package:inotes/services/local_storage/local_storage.dart';

class SessionRepositoryImpl implements SessionRepository {
  const SessionRepositoryImpl(this._storage);

  final LocalStorage _storage;

  static const _storageKey = 'session_code';
  static const _codeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  @override
  Future<Result<SessionEntity>> getCurrentSession() async {
    final code = await _storage.getString(_storageKey);
    if (code == null) return const Failure(SessionNotFoundFailure());
    return Success(SessionEntity(code: code));
  }

  @override
  Future<Result<SessionEntity>> startSession({String? code}) async {
    try {
      final sessionCode = code ?? _generateCode();
      await _storage.setString(_storageKey, sessionCode);
      return Success(SessionEntity(code: sessionCode));
    } catch (_) {
      return const Failure(SessionStorageFailure());
    }
  }

  @override
  Future<Result<void>> clearSession() async {
    try {
      await _storage.remove(_storageKey);
      return const Success(null);
    } catch (_) {
      return const Failure(SessionStorageFailure());
    }
  }

  String _generateCode() {
    final random = Random.secure();
    return List.generate(8, (_) => _codeChars[random.nextInt(_codeChars.length)]).join();
  }
}
