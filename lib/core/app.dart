import 'package:flutter/cupertino.dart';
import 'package:inotes/core/contracts/feature_app.dart';
import 'package:inotes/core/ui/ui.dart';

class App extends StatelessWidget {
  const App({super.key, required this.routes});

  final Map<String, FeatureRoute> routes;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'iNotes',
      theme: const CupertinoThemeData(brightness: Brightness.light, primaryColor: AppColors.accent),
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) => routes[settings.name]?.call(settings),
    );
  }
}
