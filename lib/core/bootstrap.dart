import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inotes/core/contracts/feature_app.dart';
import 'package:inotes/core/di/locator.dart';
import 'package:inotes/core/env/dotenv_loader.dart';
import 'package:inotes/features/home/home_feature.dart';
import 'package:inotes/features/notes/notes_feature.dart';
import 'package:inotes/services/firebase/firebase_client_impl.dart';
import 'package:inotes/services/firestore/firestore_service.dart';
import 'package:inotes/services/firestore/firestore_service_impl.dart';

Future<Map<String, FeatureRoute>> bootstrap() async {
  final env = DotenvLoader(dotenv);
  await env.load();

  final firebase = FirebaseClientImpl(env);
  await firebase.initialize();

  Locator.registerFactory<FirestoreService>(() => FirestoreServiceImpl(firebase));

  final features = <FeatureApp>[NotesFeature(), HomeFeature()];
  for (final feature in features) {
    await feature.initializeDependencies();
  }

  return features.fold<Map<String, FeatureRoute>>({}, (acc, feature) => acc..addAll(feature.routes));
}
