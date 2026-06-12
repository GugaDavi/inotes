import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:inotes/core/router/app_router.dart';
import 'package:inotes/core/router/auth_state_notifier.dart';
import 'package:inotes/core/ui/ui.dart';

class App extends StatefulWidget {
  const App({super.key, required this.authNotifier, required this.routes});

  final AuthStateNotifier authNotifier;
  final List<RouteBase> routes;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(authNotifier: widget.authNotifier, routes: widget.routes);
  }

  @override
  void dispose() {
    _appRouter.router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp.router(
      title: 'iNotes',
      theme: const CupertinoThemeData(brightness: Brightness.light, primaryColor: AppColors.accent),
      debugShowCheckedModeBanner: false,
      routerConfig: _appRouter.router,
    );
  }
}
