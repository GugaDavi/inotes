import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inotes/core/contracts/feature_app.dart';
import 'package:inotes/core/di/locator.dart';
import 'package:inotes/core/env/dotenv_loader.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/auth/auth_feature.dart';
import 'package:inotes/features/auth/domain/repositories/session_repository.dart';
import 'package:inotes/features/home/home_feature.dart';
import 'package:inotes/features/notes/notes_feature.dart';
import 'package:inotes/services/firebase/firebase_client_impl.dart';
import 'package:inotes/services/firestore/firestore_service.dart';
import 'package:inotes/services/firestore/firestore_service_impl.dart';
import 'package:inotes/services/local_storage/local_storage.dart';
import 'package:inotes/services/local_storage/local_storage_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef AppBootstrap = ({Map<String, FeatureRoute> routes, String initialRoute});

Future<AppBootstrap> bootstrap() async {
  final env = DotenvLoader(dotenv);
  await env.load();

  final firebase = FirebaseClientImpl(env);
  await firebase.initialize();

  final prefs = await SharedPreferences.getInstance();
  Locator.registerSingleton<LocalStorage>(LocalStorageImpl(prefs));
  Locator.registerFactory<FirestoreService>(() => FirestoreServiceImpl(firebase));

  final features = <FeatureApp>[AuthFeature(), NotesFeature(), HomeFeature()];
  for (final feature in features) {
    await feature.initializeDependencies();
  }

  final sessionResult = await Locator.get<SessionRepository>().getCurrentSession();
  final initialRoute = sessionResult is Success ? '/' : '/auth';

  final routes = features.fold<Map<String, FeatureRoute>>({}, (acc, feature) => acc..addAll(feature.routes));

  return (routes: routes, initialRoute: initialRoute);
}
