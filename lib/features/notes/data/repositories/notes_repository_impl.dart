import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/notes/data/models/note_model.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/domain/errors/note_failures.dart';
import 'package:inotes/features/notes/domain/repositories/notes_repository.dart';
import 'package:inotes/services/firestore/exceptions/firestore_exceptions.dart';
import 'package:inotes/services/firestore/firestore_service.dart';

class NotesRepositoryImpl implements NotesRepository {
  const NotesRepositoryImpl(this._service);

  final FirestoreService _service;

  static const _collection = 'notes';

  @override
  Future<Result<NoteEntity>> create({required String userId, required String title, required String content}) async {
    try {
      final doc = await _service.add(
        collection: _collection,
        data: {'userId': userId, 'title': title, 'content': content, 'createdAt': DateTime.now()},
      );
      return Success(NoteModel.fromMap(doc.id, doc.data));
    } on FirestoreOperationException catch (e) {
      return Failure(NoteFirestoreFailure(e.message));
    }
  }

  @override
  Future<Result<List<NoteEntity>>> getAll({required String userId}) async {
    try {
      final docs = await _service.getAll(
        collection: _collection,
        orderBy: 'createdAt',
        descending: true,
        where: {'userId': userId},
      );
      return Success(docs.map((doc) => NoteModel.fromMap(doc.id, doc.data)).toList());
    } on FirestoreOperationException catch (e) {
      return Failure(NoteFirestoreFailure(e.message));
    }
  }

  @override
  Future<Result<NoteEntity>> update({required String id, required String title, required String content}) async {
    try {
      final doc = await _service.update(collection: _collection, id: id, data: {'title': title, 'content': content});
      return Success(NoteModel.fromMap(doc.id, doc.data));
    } on DocumentNotFoundException {
      return Failure(const NoteNotFoundFailure());
    } on FirestoreOperationException catch (e) {
      return Failure(NoteFirestoreFailure(e.message));
    }
  }

  @override
  Future<Result<void>> delete({required String id}) async {
    try {
      await _service.delete(collection: _collection, id: id);
      return const Success(null);
    } on FirestoreOperationException catch (e) {
      return Failure(NoteFirestoreFailure(e.message));
    }
  }
}
