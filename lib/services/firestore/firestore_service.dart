typedef FirestoreDocument = ({String id, Map<String, dynamic> data});

abstract interface class FirestoreService {
  Future<FirestoreDocument> add({required String collection, required Map<String, dynamic> data});

  Future<List<FirestoreDocument>> getAll({required String collection, String? orderBy, bool descending = false});

  Future<FirestoreDocument> update({
    required String collection,
    required String id,
    required Map<String, dynamic> data,
  });

  Future<void> delete({required String collection, required String id});
}
