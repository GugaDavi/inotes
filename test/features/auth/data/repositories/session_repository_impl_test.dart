import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/auth/data/repositories/session_repository_impl.dart';
import 'package:inotes/features/auth/domain/entities/session_entity.dart';
import 'package:inotes/features/auth/domain/errors/auth_failures.dart';
import 'package:inotes/services/local_storage/local_storage.dart';

class MockLocalStorage extends Mock implements LocalStorage {}

void main() {
  late SessionRepositoryImpl repository;
  late MockLocalStorage mockStorage;

  setUp(() {
    mockStorage = MockLocalStorage();
    repository = SessionRepositoryImpl(mockStorage);
  });

  group('getCurrentSession', () {
    test('returns Success(SessionEntity) when code is stored', () async {
      when(() => mockStorage.getString(any())).thenAnswer((_) async => 'ABCD1234');

      final result = await repository.getCurrentSession();

      expect(result, isA<Success<SessionEntity>>());
      expect((result as Success<SessionEntity>).value.code, 'ABCD1234');
    });

    test('returns Failure(SessionNotFoundFailure) when no code is stored', () async {
      when(() => mockStorage.getString(any())).thenAnswer((_) async => null);

      final result = await repository.getCurrentSession();

      expect(result, isA<Failure<SessionEntity>>());
      expect((result as Failure<SessionEntity>).failure, isA<SessionNotFoundFailure>());
    });
  });

  group('startSession', () {
    test('saves provided code and returns Success(SessionEntity)', () async {
      when(() => mockStorage.setString(any(), any())).thenAnswer((_) async {});

      final result = await repository.startSession(code: 'ABCD1234');

      expect(result, isA<Success<SessionEntity>>());
      expect((result as Success<SessionEntity>).value.code, 'ABCD1234');
      verify(() => mockStorage.setString(any(), 'ABCD1234')).called(1);
    });

    test('generates a code when none is provided and returns Success', () async {
      when(() => mockStorage.setString(any(), any())).thenAnswer((_) async {});

      final result = await repository.startSession();

      expect(result, isA<Success<SessionEntity>>());
      final code = (result as Success<SessionEntity>).value.code;
      expect(code, isNotEmpty);
      verify(() => mockStorage.setString(any(), code)).called(1);
    });

    test('generated codes are 8 uppercase alphanumeric characters', () async {
      when(() => mockStorage.setString(any(), any())).thenAnswer((_) async {});

      final result = await repository.startSession();
      final code = (result as Success<SessionEntity>).value.code;

      expect(code.length, 8);
      expect(RegExp(r'^[A-Z0-9]{8}$').hasMatch(code), isTrue);
    });

    test('returns Failure(SessionStorageFailure) when storage throws', () async {
      when(() => mockStorage.setString(any(), any())).thenThrow(Exception('disk full'));

      final result = await repository.startSession(code: 'ABCD1234');

      expect(result, isA<Failure<SessionEntity>>());
      expect((result as Failure<SessionEntity>).failure, isA<SessionStorageFailure>());
    });
  });

  group('clearSession', () {
    test('removes stored key and returns Success(void)', () async {
      when(() => mockStorage.remove(any())).thenAnswer((_) async {});

      final result = await repository.clearSession();

      expect(result, isA<Success<void>>());
      verify(() => mockStorage.remove(any())).called(1);
    });

    test('returns Failure(SessionStorageFailure) when storage throws', () async {
      when(() => mockStorage.remove(any())).thenThrow(Exception('io error'));

      final result = await repository.clearSession();

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).failure, isA<SessionStorageFailure>());
    });
  });
}
