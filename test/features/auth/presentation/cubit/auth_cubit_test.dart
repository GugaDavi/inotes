import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/auth/domain/entities/session_entity.dart';
import 'package:inotes/features/auth/domain/errors/auth_failures.dart';
import 'package:inotes/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:inotes/features/auth/domain/usecases/start_session_use_case.dart';
import 'package:inotes/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:inotes/features/auth/presentation/cubit/auth_state.dart';

class MockGetCurrentSessionUseCase extends Mock implements GetCurrentSessionUseCase {}

class MockStartSessionUseCase extends Mock implements StartSessionUseCase {}

void main() {
  late MockGetCurrentSessionUseCase mockGetSession;
  late MockStartSessionUseCase mockStartSession;

  const tSession = SessionEntity(code: 'ABCD1234');

  setUp(() {
    mockGetSession = MockGetCurrentSessionUseCase();
    mockStartSession = MockStartSessionUseCase();
  });

  group('AuthCubit', () {
    test('initial state is AuthInitial', () {
      final cubit = AuthCubit(mockGetSession, mockStartSession);
      expect(cubit.state, isA<AuthInitial>());
      cubit.close();
    });

    group('checkSession', () {
      blocTest<AuthCubit, AuthState>(
        'emits AuthAuthenticated when session exists',
        build: () => AuthCubit(mockGetSession, mockStartSession),
        setUp: () {
          when(() => mockGetSession.execute()).thenAnswer((_) async => const Success(tSession));
        },
        act: (cubit) => cubit.checkSession(),
        expect: () => [isA<AuthAuthenticated>()],
      );

      blocTest<AuthCubit, AuthState>(
        'emits AuthInitial when no session exists',
        build: () => AuthCubit(mockGetSession, mockStartSession),
        setUp: () {
          when(() => mockGetSession.execute())
              .thenAnswer((_) async => const Failure(SessionNotFoundFailure()));
        },
        act: (cubit) => cubit.checkSession(),
        expect: () => [isA<AuthInitial>()],
      );
    });

    group('enterCode', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on success',
        build: () => AuthCubit(mockGetSession, mockStartSession),
        setUp: () {
          when(() => mockStartSession.execute(code: any(named: 'code')))
              .thenAnswer((_) async => const Success(tSession));
        },
        act: (cubit) => cubit.enterCode('ABCD1234'),
        expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
      );

      blocTest<AuthCubit, AuthState>(
        'emits AuthError when code is empty',
        build: () => AuthCubit(mockGetSession, mockStartSession),
        act: (cubit) => cubit.enterCode(''),
        expect: () => [isA<AuthError>()],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when repository fails',
        build: () => AuthCubit(mockGetSession, mockStartSession),
        setUp: () {
          when(() => mockStartSession.execute(code: any(named: 'code')))
              .thenAnswer((_) async => const Failure(SessionStorageFailure()));
        },
        act: (cubit) => cubit.enterCode('ABCD1234'),
        expect: () => [isA<AuthLoading>(), isA<AuthError>()],
      );
    });

    group('startNewSession', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthSessionCreated] with generated code',
        build: () => AuthCubit(mockGetSession, mockStartSession),
        setUp: () {
          when(() => mockStartSession.execute(code: null))
              .thenAnswer((_) async => const Success(tSession));
        },
        act: (cubit) => cubit.startNewSession(),
        expect: () => [isA<AuthLoading>(), AuthSessionCreated(tSession.code)],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when generation fails',
        build: () => AuthCubit(mockGetSession, mockStartSession),
        setUp: () {
          when(() => mockStartSession.execute(code: null))
              .thenAnswer((_) async => const Failure(SessionStorageFailure()));
        },
        act: (cubit) => cubit.startNewSession(),
        expect: () => [isA<AuthLoading>(), isA<AuthError>()],
      );
    });

    group('confirmNewSession', () {
      blocTest<AuthCubit, AuthState>(
        'emits AuthAuthenticated',
        build: () => AuthCubit(mockGetSession, mockStartSession),
        act: (cubit) => cubit.confirmNewSession(),
        expect: () => [isA<AuthAuthenticated>()],
      );
    });
  });
}
