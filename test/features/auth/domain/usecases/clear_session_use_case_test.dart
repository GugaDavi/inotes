import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/auth/domain/errors/auth_failures.dart';
import 'package:inotes/features/auth/domain/repositories/session_repository.dart';
import 'package:inotes/features/auth/domain/usecases/clear_session_use_case.dart';

class MockSessionRepository extends Mock implements SessionRepository {}

void main() {
  late ClearSessionUseCase useCase;
  late MockSessionRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionRepository();
    useCase = ClearSessionUseCase(mockRepository);
  });

  group('ClearSessionUseCase', () {
    test('returns Success(void) when session is cleared', () async {
      when(() => mockRepository.clearSession()).thenAnswer((_) async => const Success(null));

      final result = await useCase.execute();

      expect(result, isA<Success<void>>());
      verify(() => mockRepository.clearSession()).called(1);
    });

    test('returns Failure when repository fails', () async {
      when(() => mockRepository.clearSession())
          .thenAnswer((_) async => const Failure(SessionStorageFailure()));

      final result = await useCase.execute();

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).failure, isA<SessionStorageFailure>());
    });
  });
}
