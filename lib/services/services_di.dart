import 'package:inotes/core/di/locator.dart';
import 'package:inotes/services/firebase/firebase_client_impl.dart';
import 'package:inotes/services/firestore/firestore_service.dart';
import 'package:inotes/services/firestore/firestore_service_impl.dart';
import 'package:inotes/services/local_storage/local_storage.dart';
import 'package:inotes/services/local_storage/local_storage_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServicesDI {
  static void initialize({required FirebaseClientImpl firebase, required SharedPreferences prefs}) {
    Locator.registerSingleton<LocalStorage>(LocalStorageImpl(prefs));
    Locator.registerFactory<FirestoreService>(() => FirestoreServiceImpl(firebase));
  }
}
