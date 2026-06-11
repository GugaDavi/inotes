import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inotes/core/contracts/feature_app.dart';
import 'package:inotes/core/di/locator.dart';
import 'package:inotes/core/env/dotenv_loader.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/core/router/auth_state_notifier.dart';
import 'package:inotes/features/auth/auth_feature.dart';
import 'package:inotes/features/auth/domain/repositories/session_repository.dart';
import 'package:inotes/features/home/home_feature.dart';
import 'package:inotes/features/notes/notes_feature.dart';
import 'package:inotes/services/firebase/firebase_client_impl.dart';
import 'package:inotes/services/services_di.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AuthStateNotifier> bootstrap() async {
  final env = DotenvLoader(dotenv);
  await env.load();

  final firebase = FirebaseClientImpl(env);
  await firebase.initialize();
  await firebase.signInAnonymously();

  final prefs = await SharedPreferences.getInstance();
  ServicesDI.initialize(firebase: firebase, prefs: prefs);

  final features = <FeatureApp>[AuthFeature(), NotesFeature(), HomeFeature()];
  for (final feature in features) {
    await feature.initializeDependencies();
  }

  final sessionResult = await Locator.get<SessionRepository>().getCurrentSession();
  final isAuthenticated = sessionResult is Success;

  final authNotifier = AuthStateNotifier(isAuthenticated: isAuthenticated);
  Locator.registerSingleton<AuthStateNotifier>(authNotifier);

  return authNotifier;
}
