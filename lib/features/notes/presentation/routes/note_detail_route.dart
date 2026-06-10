import 'package:flutter/cupertino.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/presentation/pages/note_detail_page.dart';

class NoteDetailRoute extends PageRouteBuilder<dynamic> {
  NoteDetailRoute(RouteSettings? settings)
    : super(
        settings: settings,
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          final note = settings?.arguments as NoteEntity?;
          return NoteDetailPage(note: note);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          final scale = Tween<double>(begin: 0.5, end: 1.0).animate(curved);
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(scale: scale, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
      );
}
