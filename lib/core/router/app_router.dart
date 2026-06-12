import 'package:go_router/go_router.dart';
import 'package:inotes/core/router/auth_state_notifier.dart';

class AppRouter {
  AppRouter({required AuthStateNotifier authNotifier, required List<RouteBase> routes}) {
    _router = GoRouter(
      initialLocation: authNotifier.isAuthenticated ? '/' : '/auth',
      refreshListenable: authNotifier,
      redirect: (context, state) {
        final isAuth = authNotifier.isAuthenticated;
        final onAuth = state.matchedLocation.startsWith('/auth');
        if (!isAuth && !onAuth) return '/auth';
        if (isAuth && onAuth) return '/';
        return null;
      },
      routes: routes,
    );
  }

  late final GoRouter _router;
  GoRouter get router => _router;
}
