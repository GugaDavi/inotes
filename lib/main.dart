import 'package:flutter/widgets.dart';
import 'package:inotes/core/app.dart';
import 'package:inotes/core/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final routes = await bootstrap();
  runApp(App(routes: routes));
}
