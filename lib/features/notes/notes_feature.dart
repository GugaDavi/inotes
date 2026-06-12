import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:inotes/core/contracts/feature_app.dart';
import 'package:inotes/core/di/locator.dart';
import 'package:inotes/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:inotes/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/domain/repositories/notes_repository.dart';
import 'package:inotes/features/notes/domain/usecases/create_note_use_case.dart';
import 'package:inotes/features/notes/domain/usecases/delete_note_use_case.dart';
import 'package:inotes/features/notes/domain/usecases/get_notes_use_case.dart';
import 'package:inotes/features/notes/domain/usecases/update_note_use_case.dart';
import 'package:inotes/features/notes/presentation/cubit/note_detail_cubit.dart';
import 'package:inotes/features/notes/presentation/pages/note_detail_page.dart';
import 'package:inotes/features/tags/domain/usecases/get_tags_use_case.dart';
import 'package:inotes/services/firestore/firestore_service.dart';

class NotesFeature implements FeatureApp {
  @override
  Future<void> initializeDependencies() async {
    await _dataLayer();
    await _domainLayer();
    await _presentationLayer();
  }

  Future<void> _dataLayer() async {
    Locator.registerFactory<NotesRepository>(() => NotesRepositoryImpl(Locator.get<FirestoreService>()));
  }

  Future<void> _domainLayer() async {
    Locator.registerFactory<GetNotesUseCase>(() => GetNotesUseCase(Locator.get<NotesRepository>()));
    Locator.registerFactory<CreateNoteUseCase>(() => CreateNoteUseCase(Locator.get<NotesRepository>()));
    Locator.registerFactory<UpdateNoteUseCase>(() => UpdateNoteUseCase(Locator.get<NotesRepository>()));
    Locator.registerFactory<DeleteNoteUseCase>(() => DeleteNoteUseCase(Locator.get<NotesRepository>()));
  }

  Future<void> _presentationLayer() async {
    Locator.registerFactory<NoteDetailCubit>(
      () => NoteDetailCubit(
        Locator.get<CreateNoteUseCase>(),
        Locator.get<UpdateNoteUseCase>(),
        Locator.get<DeleteNoteUseCase>(),
        Locator.get<GetCurrentSessionUseCase>(),
        Locator.get<GetTagsUseCase>(),
      ),
    );
  }

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: '/note',
      pageBuilder: (context, state) {
        final note = state.extra as NoteEntity?;
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: false,
          barrierDismissible: false,
          child: NoteDetailPage(note: note),
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
