import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:inotes/core/app.dart';
import 'package:inotes/core/bootstrap.dart';
import 'package:inotes/features/splash/presentation/splash_app.dart';

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const SplashApp());

  final (:notifier, :routes) = await bootstrap();

  runApp(App(authNotifier: notifier, routes: routes));
}
