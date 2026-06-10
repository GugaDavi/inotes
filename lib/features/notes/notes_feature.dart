import 'package:inotes/core/contracts/feature_app.dart';
import 'package:inotes/core/di/locator.dart';
import 'package:inotes/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:inotes/features/notes/domain/repositories/notes_repository.dart';
import 'package:inotes/features/notes/domain/usecases/create_note_use_case.dart';
import 'package:inotes/features/notes/domain/usecases/delete_note_use_case.dart';
import 'package:inotes/features/notes/domain/usecases/get_notes_use_case.dart';
import 'package:inotes/features/notes/domain/usecases/update_note_use_case.dart';
import 'package:inotes/features/notes/presentation/cubit/note_detail_cubit.dart';
import 'package:inotes/features/notes/presentation/routes/note_detail_route.dart';
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
      ),
    );
  }

  @override
  Map<String, FeatureRoute> get routes => {'/note': (settings) => NoteDetailRoute(settings)};
}
