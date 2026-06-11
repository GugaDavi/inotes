import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inotes/core/env/env_loader.dart';
import 'package:inotes/services/firebase/firebase_client.dart';

class FirebaseClientImpl implements FirebaseClient {
  FirebaseClientImpl(this._envLoader);

  final EnvLoader _envLoader;

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: _envLoader.get('FIREBASE_API_KEY'),
        authDomain: _envLoader.get('FIREBASE_AUTH_DOMAIN'),
        projectId: _envLoader.get('FIREBASE_PROJECT_ID'),
        storageBucket: _envLoader.get('FIREBASE_STORAGE_BUCKET'),
        messagingSenderId: _envLoader.get('FIREBASE_MESSAGING_SENDER_ID'),
        appId: _envLoader.get('FIREBASE_APP_ID'),
        measurementId: _envLoader.get('FIREBASE_MEASUREMENT_ID'),
      ),
    );
  }

  @override
  Future<void> signInAnonymously() async {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  }

  @override
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
}
