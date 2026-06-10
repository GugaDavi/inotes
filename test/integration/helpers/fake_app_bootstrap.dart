import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:inotes/core/contracts/feature_app.dart';
import 'package:inotes/core/di/locator.dart';
import 'package:inotes/features/home/home_feature.dart';
import 'package:inotes/features/notes/notes_feature.dart';
import 'package:inotes/services/firebase/firebase_client.dart';
import 'package:inotes/services/firestore/firestore_service.dart';
import 'package:inotes/services/firestore/firestore_service_impl.dart';

typedef AppTestSetup = ({Map<String, FeatureRoute> routes, FakeFirebaseFirestore fakeFirestore});

class _FakeFirebaseClient implements FirebaseClient {
  _FakeFirebaseClient(this._firestore);

  final FakeFirebaseFirestore _firestore;

  @override
  Future<void> initialize() async {}

  @override
  FirebaseFirestore get firestore => _firestore;
}

Future<AppTestSetup> fakeBootstrap() async {
  await GetIt.instance.reset();

  final fakeFirestore = FakeFirebaseFirestore();
  final fakeClient = _FakeFirebaseClient(fakeFirestore);

  Locator.registerFactory<FirestoreService>(() => FirestoreServiceImpl(fakeClient));

  final features = <FeatureApp>[NotesFeature(), HomeFeature()];
  for (final feature in features) {
    await feature.initializeDependencies();
  }

  final routes = features.fold<Map<String, FeatureRoute>>({}, (acc, feature) => acc..addAll(feature.routes));

  return (routes: routes, fakeFirestore: fakeFirestore);
}
