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
  final tData = {
    'title': 'Title',
    'content': 'Content',
    'createdAt': tCreatedAt,
  };
  final tDocument = (id: '1', data: tData);
  final tNote = NoteModel(
    id: '1',
    title: 'Title',
    content: 'Content',
    createdAt: tCreatedAt,
  );

  group('create', () {
    test('returns Success(NoteEntity) on service success', () async {
      when(() => mockService.add(collection: any(named: 'collection'), data: any(named: 'data')))
          .thenAnswer((_) async => tDocument);

      final result = await repository.create(title: 'Title', content: 'Content');

      expect(result, isA<Success<NoteEntity>>());
      expect((result as Success<NoteEntity>).value, tNote);
    });

    test('returns Failure(NoteFirestoreFailure) on FirestoreOperationException', () async {
      when(() => mockService.add(collection: any(named: 'collection'), data: any(named: 'data')))
          .thenThrow(const FirestoreOperationException());

      final result = await repository.create(title: 'Title', content: 'Content');

      expect(result, isA<Failure<NoteEntity>>());
      expect((result as Failure<NoteEntity>).failure, isA<NoteFirestoreFailure>());
    });
  });

  group('getAll', () {
    test('returns Success(List<NoteEntity>) on service success', () async {
      when(() => mockService.getAll(
            collection: any(named: 'collection'),
            orderBy: any(named: 'orderBy'),
            descending: any(named: 'descending'),
          )).thenAnswer((_) async => [tDocument]);

      final result = await repository.getAll();

      expect(result, isA<Success<List<NoteEntity>>>());
      expect((result as Success<List<NoteEntity>>).value, [tNote]);
    });

    test('returns Failure(NoteFirestoreFailure) on FirestoreOperationException', () async {
      when(() => mockService.getAll(
            collection: any(named: 'collection'),
            orderBy: any(named: 'orderBy'),
            descending: any(named: 'descending'),
          )).thenThrow(const FirestoreOperationException());

      final result = await repository.getAll();

      expect(result, isA<Failure<List<NoteEntity>>>());
      expect((result as Failure<List<NoteEntity>>).failure, isA<NoteFirestoreFailure>());
    });
  });

  group('update', () {
    test('returns Success(NoteEntity) on service success', () async {
      when(() => mockService.update(
            collection: any(named: 'collection'),
            id: any(named: 'id'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => tDocument);

      final result = await repository.update(id: '1', title: 'Title', content: 'Content');

      expect(result, isA<Success<NoteEntity>>());
      expect((result as Success<NoteEntity>).value, tNote);
    });

    test('returns Failure(NoteNotFoundFailure) on DocumentNotFoundException', () async {
      when(() => mockService.update(
            collection: any(named: 'collection'),
            id: any(named: 'id'),
            data: any(named: 'data'),
          )).thenThrow(const DocumentNotFoundException());

      final result = await repository.update(id: '1', title: 'Title', content: 'Content');

      expect(result, isA<Failure<NoteEntity>>());
      expect((result as Failure<NoteEntity>).failure, isA<NoteNotFoundFailure>());
    });

    test('returns Failure(NoteFirestoreFailure) on FirestoreOperationException', () async {
      when(() => mockService.update(
            collection: any(named: 'collection'),
            id: any(named: 'id'),
            data: any(named: 'data'),
          )).thenThrow(const FirestoreOperationException());

      final result = await repository.update(id: '1', title: 'Title', content: 'Content');

      expect(result, isA<Failure<NoteEntity>>());
      expect((result as Failure<NoteEntity>).failure, isA<NoteFirestoreFailure>());
    });
  });

  group('delete', () {
    test('returns Success(void) on service success', () async {
      when(() => mockService.delete(collection: any(named: 'collection'), id: any(named: 'id')))
          .thenAnswer((_) async {});

      final result = await repository.delete(id: '1');

      expect(result, isA<Success<void>>());
    });

    test('returns Failure(NoteFirestoreFailure) on FirestoreOperationException', () async {
      when(() => mockService.delete(collection: any(named: 'collection'), id: any(named: 'id')))
          .thenThrow(const FirestoreOperationException());

      final result = await repository.delete(id: '1');

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).failure, isA<NoteFirestoreFailure>());
    });
  });
}
