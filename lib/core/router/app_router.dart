import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:inotes/core/router/auth_state_notifier.dart';
import 'package:inotes/features/auth/presentation/pages/auth_page.dart';
import 'package:inotes/features/home/presentation/pages/home_page.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/presentation/pages/note_detail_page.dart';

class AppRouter {
  AppRouter({required AuthStateNotifier authNotifier}) {
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
      routes: [..._authRoutes, ..._homeRoutes],
    );
  }

  late final GoRouter _router;
  GoRouter get router => _router;

  static List<RouteBase> get _authRoutes => [GoRoute(path: '/auth', builder: (context, state) => const AuthPage())];

  static List<RouteBase> get _homeRoutes => [
    GoRoute(path: '/', builder: (context, state) => const HomePage(), routes: _noteRoutes),
  ];

  static List<RouteBase> get _noteRoutes => [
    GoRoute(
      path: 'notes/:noteId',
      pageBuilder: (context, state) {
        final noteId = state.pathParameters['noteId']!;
        final note = state.extra as NoteEntity?;
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: false,
          barrierDismissible: false,
          child: NoteDetailPage(noteId: noteId, note: note),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(scale: Tween<double>(begin: 0.5, end: 1.0).animate(curved), child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 220),
        );
      },
    ),
  ];
}
