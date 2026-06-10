import 'package:flutter/cupertino.dart';
import 'package:inotes/core/contracts/feature_app.dart';

class App extends StatelessWidget {
  const App({super.key, required this.routes});

  final Map<String, FeatureRoute> routes;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'iNotes',
      theme: const CupertinoThemeData(brightness: Brightness.light, primaryColor: Color(0xFFFFD60A)),
      initialRoute: '/',
      onGenerateRoute: (settings) => routes[settings.name]?.call(settings),
    );
  }
}
