import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/auth/domain/entities/session_entity.dart';
import 'package:inotes/features/auth/domain/errors/auth_failures.dart';
import 'package:inotes/features/auth/domain/repositories/session_repository.dart';
import 'package:inotes/features/auth/domain/usecases/start_session_use_case.dart';

class MockSessionRepository extends Mock implements SessionRepository {}

void main() {
  late StartSessionUseCase useCase;
  late MockSessionRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionRepository();
    useCase = StartSessionUseCase(mockRepository);
  });

  group('StartSessionUseCase', () {
    test('calls repository with provided code and returns Success', () async {
      when(
        () => mockRepository.startSession(code: any(named: 'code')),
      ).thenAnswer((_) async => const Success(SessionEntity(code: 'ABCD1234')));

      final result = await useCase.execute(code: 'ABCD1234');

      expect(result, isA<Success<SessionEntity>>());
      expect((result as Success<SessionEntity>).value.code, 'ABCD1234');
      verify(() => mockRepository.startSession(code: 'ABCD1234')).called(1);
    });

    test('calls repository with no code when generating new session', () async {
      when(
        () => mockRepository.startSession(code: any(named: 'code')),
      ).thenAnswer((_) async => const Success(SessionEntity(code: 'NEWCODE1')));

      final result = await useCase.execute();

      expect(result, isA<Success<SessionEntity>>());
      verify(() => mockRepository.startSession(code: null)).called(1);
    });

    test('returns Failure when repository fails', () async {
      when(
        () => mockRepository.startSession(code: any(named: 'code')),
      ).thenAnswer((_) async => const Failure(SessionStorageFailure()));

      final result = await useCase.execute(code: 'ABCD1234');

      expect(result, isA<Failure<SessionEntity>>());
      expect((result as Failure<SessionEntity>).failure, isA<SessionStorageFailure>());
    });
  });
}
