import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/notes/data/models/note_model.dart';
import 'package:inotes/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/domain/errors/note_failures.dart';
import 'package:inotes/services/firestore/exceptions/firestore_exceptions.dart';
import 'package:inotes/services/firestore/firestore_service.dart';

class MockFirestoreService extends Mock implements FirestoreService {}

void main() {
  late NotesRepositoryImpl repository;
  late MockFirestoreService mockService;

  setUp(() {
    mockService = MockFirestoreService();
    repository = NotesRepositoryImpl(mockService);
  });

  final tCreatedAt = DateTime(2026, 6, 10);
  final tData = {'userId': 'user-a', 'title': 'Title', 'content': 'Content', 'createdAt': tCreatedAt};
  final tDocument = (id: '1', data: tData);
  final tNote = NoteModel(id: '1', userId: 'user-a', title: 'Title', content: 'Content', createdAt: tCreatedAt);

  group('create', () {
    test('returns Success(NoteEntity) on service success', () async {
      when(
        () => mockService.add(
          collection: any(named: 'collection'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => tDocument);

      final result = await repository.create(userId: 'user-a', title: 'Title', content: 'Content');

      expect(result, isA<Success<NoteEntity>>());
      expect((result as Success<NoteEntity>).value, tNote);
    });

    test('includes userId in stored data', () async {
      Map<String, dynamic>? capturedData;
      when(
        () => mockService.add(
          collection: any(named: 'collection'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((inv) async {
        capturedData = inv.namedArguments[const Symbol('data')] as Map<String, dynamic>;
        return tDocument;
      });

      await repository.create(userId: 'user-a', title: 'Title', content: 'Content');

      expect(capturedData!['userId'], 'user-a');
    });

    test('returns Failure(NoteFirestoreFailure) on FirestoreOperationException', () async {
      when(
        () => mockService.add(
          collection: any(named: 'collection'),
          data: any(named: 'data'),
        ),
      ).thenThrow(const FirestoreOperationException());

      final result = await repository.create(userId: 'user-a', title: 'Title', content: 'Content');

      expect(result, isA<Failure<NoteEntity>>());
      expect((result as Failure<NoteEntity>).failure, isA<NoteFirestoreFailure>());
    });
  });

  group('getAll', () {
    test('returns Success(List<NoteEntity>) on service success', () async {
      when(
        () => mockService.getAll(
          collection: any(named: 'collection'),
          where: any(named: 'where'),
        ),
      ).thenAnswer((_) async => [tDocument]);

      final result = await repository.getAll(userId: 'user-a');

      expect(result, isA<Success<List<NoteEntity>>>());
      expect((result as Success<List<NoteEntity>>).value, [tNote]);
    });

    test('returns Success([]) when service returns no documents', () async {
      when(
        () => mockService.getAll(
          collection: any(named: 'collection'),
          where: any(named: 'where'),
        ),
      ).thenAnswer((_) async => []);

      final result = await repository.getAll(userId: 'user-a');

      expect(result, isA<Success<List<NoteEntity>>>());
      expect((result as Success<List<NoteEntity>>).value, isEmpty);
    });

    test('returns notes sorted by createdAt descending', () async {
      final older = {'userId': 'user-a', 'title': 'Old', 'content': '', 'createdAt': DateTime(2026, 1, 1)};
      final newer = {'userId': 'user-a', 'title': 'New', 'content': '', 'createdAt': DateTime(2026, 6, 1)};
      when(
        () => mockService.getAll(
          collection: any(named: 'collection'),
          where: any(named: 'where'),
        ),
      ).thenAnswer((_) async => [(id: 'a', data: older), (id: 'b', data: newer)]);

      final result = await repository.getAll(userId: 'user-a');

      final notes = (result as Success<List<NoteEntity>>).value;
      expect(notes.first.createdAt, DateTime(2026, 6, 1));
      expect(notes.last.createdAt, DateTime(2026, 1, 1));
    });

    test('filters by userId via where param', () async {
      Map<String, Object?>? capturedWhere;
      when(
        () => mockService.getAll(
          collection: any(named: 'collection'),
          where: any(named: 'where'),
        ),
      ).thenAnswer((inv) async {
        capturedWhere = inv.namedArguments[const Symbol('where')] as Map<String, Object?>?;
        return [tDocument];
      });

      await repository.getAll(userId: 'user-a');

      expect(capturedWhere, {'userId': 'user-a'});
    });

    test('returns Failure(NoteFirestoreFailure) on FirestoreOperationException', () async {
      when(
        () => mockService.getAll(
          collection: any(named: 'collection'),
          where: any(named: 'where'),
        ),
      ).thenThrow(const FirestoreOperationException());

      final result = await repository.getAll(userId: 'user-a');

      expect(result, isA<Failure<List<NoteEntity>>>());
      expect((result as Failure<List<NoteEntity>>).failure, isA<NoteFirestoreFailure>());
    });
  });

  group('update', () {
    test('returns Success(NoteEntity) on service success', () async {
      when(
        () => mockService.update(
          collection: any(named: 'collection'),
          id: any(named: 'id'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => tDocument);

      final result = await repository.update(id: '1', title: 'Title', content: 'Content');

      expect(result, isA<Success<NoteEntity>>());
      expect((result as Success<NoteEntity>).value, tNote);
    });

    test('returns Failure(NoteNotFoundFailure) on DocumentNotFoundException', () async {
      when(
        () => mockService.update(
          collection: any(named: 'collection'),
          id: any(named: 'id'),
          data: any(named: 'data'),
        ),
      ).thenThrow(const DocumentNotFoundException());

      final result = await repository.update(id: '1', title: 'Title', content: 'Content');

      expect(result, isA<Failure<NoteEntity>>());
      expect((result as Failure<NoteEntity>).failure, isA<NoteNotFoundFailure>());
    });

    test('returns Failure(NoteFirestoreFailure) on FirestoreOperationException', () async {
      when(
        () => mockService.update(
          collection: any(named: 'collection'),
          id: any(named: 'id'),
          data: any(named: 'data'),
        ),
      ).thenThrow(const FirestoreOperationException());

      final result = await repository.update(id: '1', title: 'Title', content: 'Content');

      expect(result, isA<Failure<NoteEntity>>());
      expect((result as Failure<NoteEntity>).failure, isA<NoteFirestoreFailure>());
    });
  });

  group('getById', () {
    test('returns Success(NoteEntity) on service success', () async {
      when(
        () => mockService.get(
          collection: any(named: 'collection'),
          id: any(named: 'id'),
        ),
      ).thenAnswer((_) async => tDocument);

      final result = await repository.getById(id: '1');

      expect(result, isA<Success<NoteEntity>>());
      expect((result as Success<NoteEntity>).value, tNote);
    });

    test('returns Failure(NoteNotFoundFailure) on DocumentNotFoundException', () async {
      when(
        () => mockService.get(
          collection: any(named: 'collection'),
          id: any(named: 'id'),
        ),
      ).thenThrow(const DocumentNotFoundException());

      final result = await repository.getById(id: '1');

      expect(result, isA<Failure<NoteEntity>>());
      expect((result as Failure<NoteEntity>).failure, isA<NoteNotFoundFailure>());
    });

    test('returns Failure(NoteFirestoreFailure) on FirestoreOperationException', () async {
      when(
        () => mockService.get(
          collection: any(named: 'collection'),
          id: any(named: 'id'),
        ),
      ).thenThrow(const FirestoreOperationException());

      final result = await repository.getById(id: '1');

      expect(result, isA<Failure<NoteEntity>>());
      expect((result as Failure<NoteEntity>).failure, isA<NoteFirestoreFailure>());
    });
  });

  group('delete', () {
    test('returns Success(void) on service success', () async {
      when(
        () => mockService.delete(
          collection: any(named: 'collection'),
          id: any(named: 'id'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.delete(id: '1');

      expect(result, isA<Success<void>>());
    });

    test('returns Failure(NoteFirestoreFailure) on FirestoreOperationException', () async {
      when(
        () => mockService.delete(
          collection: any(named: 'collection'),
          id: any(named: 'id'),
        ),
      ).thenThrow(const FirestoreOperationException());

      final result = await repository.delete(id: '1');

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).failure, isA<NoteFirestoreFailure>());
    });
  });
}
