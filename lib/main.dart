import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:inotes/core/app.dart';
import 'package:inotes/core/bootstrap.dart';
import 'package:inotes/features/splash/presentation/splash_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(SplashApp());

  final (:routes, :initialRoute) = await bootstrap();

  final target = routes.containsKey(initialRoute) ? initialRoute : '/';

  runApp(App(routes: routes, initialRoute: target));
}
