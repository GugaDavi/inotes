sealed class FirestoreException implements Exception {
  const FirestoreException();
}

final class DocumentNotFoundException extends FirestoreException {
  const DocumentNotFoundException();
}

final class FirestoreOperationException extends FirestoreException {
  const FirestoreOperationException([this.message]);

  final String? message;
}
