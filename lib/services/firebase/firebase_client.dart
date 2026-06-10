import 'package:cloud_firestore/cloud_firestore.dart';

abstract interface class FirebaseClient {
  Future<void> initialize();
  FirebaseFirestore get firestore;
}
