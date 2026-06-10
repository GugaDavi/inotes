import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inotes/services/firebase/firebase_client.dart';
import 'package:inotes/services/firestore/exceptions/firestore_exceptions.dart';
import 'package:inotes/services/firestore/firestore_service.dart';

class FirestoreServiceImpl implements FirestoreService {
  const FirestoreServiceImpl(this._client);

  final FirebaseClient _client;

  CollectionReference<Map<String, dynamic>> _collection(String name) => _client.firestore.collection(name);

  Map<String, dynamic> _toFirestore(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is DateTime) return MapEntry(key, Timestamp.fromDate(value));
      return MapEntry(key, value);
    });
  }

  Map<String, dynamic> _fromFirestore(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is Timestamp) return MapEntry(key, value.toDate());
      return MapEntry(key, value);
    });
  }

  @override
  Future<FirestoreDocument> add({required String collection, required Map<String, dynamic> data}) async {
    try {
      final doc = _collection(collection).doc();
      await doc.set(_toFirestore(data));
      return (id: doc.id, data: data);
    } on FirebaseException catch (e) {
      throw FirestoreOperationException(e.message);
    }
  }

  @override
  Future<List<FirestoreDocument>> getAll({required String collection, String? orderBy, bool descending = false}) async {
    try {
      Query<Map<String, dynamic>> query = _collection(collection);
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => (id: doc.id, data: _fromFirestore(doc.data()))).toList();
    } on FirebaseException catch (e) {
      throw FirestoreOperationException(e.message);
    }
  }

  @override
  Future<FirestoreDocument> update({
    required String collection,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final doc = _collection(collection).doc(id);
      await doc.update(_toFirestore(data));
      final snapshot = await doc.get();
      return (id: id, data: _fromFirestore(snapshot.data()!));
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') throw const DocumentNotFoundException();
      throw FirestoreOperationException(e.message);
    }
  }

  @override
  Future<void> delete({required String collection, required String id}) async {
    try {
      await _collection(collection).doc(id).delete();
    } on FirebaseException catch (e) {
      throw FirestoreOperationException(e.message);
    }
  }
}
