import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/auth/domain/entities/session_entity.dart';
import 'package:inotes/features/auth/domain/errors/auth_failures.dart';
import 'package:inotes/features/auth/domain/repositories/session_repository.dart';
import 'package:inotes/features/auth/domain/usecases/get_current_session_use_case.dart';

class MockSessionRepository extends Mock implements SessionRepository {}

void main() {
  late GetCurrentSessionUseCase useCase;
  late MockSessionRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionRepository();
    useCase = GetCurrentSessionUseCase(mockRepository);
  });

  group('GetCurrentSessionUseCase', () {
    const tSession = SessionEntity(code: 'ABCD1234');

    test('returns Success(SessionEntity) when session exists', () async {
      when(() => mockRepository.getCurrentSession()).thenAnswer((_) async => const Success(tSession));

      final result = await useCase.execute();

      expect(result, isA<Success<SessionEntity>>());
      expect((result as Success<SessionEntity>).value, tSession);
      verify(() => mockRepository.getCurrentSession()).called(1);
    });

    test('returns Failure(SessionNotFoundFailure) when no session exists', () async {
      when(() => mockRepository.getCurrentSession())
          .thenAnswer((_) async => const Failure(SessionNotFoundFailure()));

      final result = await useCase.execute();

      expect(result, isA<Failure<SessionEntity>>());
      expect((result as Failure<SessionEntity>).failure, isA<SessionNotFoundFailure>());
    });
  });
}
