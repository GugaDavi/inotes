import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:inotes/core/contracts/feature_app.dart';
import 'package:inotes/core/di/locator.dart';
import 'package:inotes/core/router/auth_state_notifier.dart';
import 'package:inotes/features/auth/auth_feature.dart';
import 'package:inotes/features/home/home_feature.dart';
import 'package:inotes/features/notes/notes_feature.dart';
import 'package:inotes/services/firebase/firebase_client.dart';
import 'package:inotes/services/firestore/firestore_service.dart';
import 'package:inotes/services/firestore/firestore_service_impl.dart';
import 'package:inotes/services/local_storage/local_storage.dart';

const testSessionCode = 'TEST0001';

typedef AppTestSetup = ({AuthStateNotifier notifier, List<RouteBase> routes, FakeFirebaseFirestore fakeFirestore});

class _FakeFirebaseClient implements FirebaseClient {
  _FakeFirebaseClient(this._firestore);

  final FakeFirebaseFirestore _firestore;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> signInAnonymously() async {}

  @override
  FirebaseFirestore get firestore => _firestore;
}

class _FakeLocalStorage implements LocalStorage {
  _FakeLocalStorage({this.sessionCode = testSessionCode});

  final String? sessionCode;

  @override
  Future<String?> getString(String key) async => sessionCode;

  @override
  Future<void> setString(String key, String value) async {}

  @override
  Future<void> remove(String key) async {}
}

Future<AppTestSetup> fakeBootstrap({bool authenticated = true}) async {
  await GetIt.instance.reset();

  final fakeFirestore = FakeFirebaseFirestore();
  final fakeClient = _FakeFirebaseClient(fakeFirestore);

  Locator.registerSingleton<LocalStorage>(_FakeLocalStorage(sessionCode: authenticated ? testSessionCode : null));
  Locator.registerFactory<FirestoreService>(() => FirestoreServiceImpl(fakeClient));

  final features = <FeatureApp>[AuthFeature(), NotesFeature(), HomeFeature()];
  for (final feature in features) {
    await feature.initializeDependencies();
  }

  final authNotifier = AuthStateNotifier(isAuthenticated: authenticated);
  Locator.registerSingleton<AuthStateNotifier>(authNotifier);

  final routes = [for (final feature in features) ...feature.routes];

  return (notifier: authNotifier, routes: routes, fakeFirestore: fakeFirestore);
}

extension FakeFirestoreNoteSeeder on FakeFirebaseFirestore {
  Future<void> seedNote({required String title, required String content, required DateTime createdAt}) {
    return collection(
      'notes',
    ).add({'userId': testSessionCode, 'title': title, 'content': content, 'createdAt': Timestamp.fromDate(createdAt)});
  }
}
