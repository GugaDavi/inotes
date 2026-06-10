import 'package:inotes/core/contracts/feature_app.dart';
import 'package:inotes/core/di/locator.dart';
import 'package:inotes/features/home/presentation/cubit/home_cubit.dart';
import 'package:inotes/features/home/presentation/pages/home_page.dart';
import 'package:inotes/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:inotes/features/notes/domain/repositories/notes_repository.dart';
import 'package:inotes/features/notes/domain/usecases/get_notes.dart';
import 'package:inotes/services/firestore/firestore_service.dart';

class HomeFeature implements FeatureApp {
  @override
  Future<void> initializeDependencies() async {
    await _dataLayer();
    await _domainLayer();
    await _presentationLayer();
  }

  Future<void> _dataLayer() async {
    Locator.registerFactory<NotesRepository>(
      () => NotesRepositoryImpl(Locator.get<FirestoreService>()),
    );
  }

  Future<void> _domainLayer() async {
    Locator.registerFactory<GetNotes>(
      () => GetNotes(Locator.get<NotesRepository>()),
    );
  }

  Future<void> _presentationLayer() async {
    Locator.registerFactory<HomeCubit>(
      () => HomeCubit(Locator.get<GetNotes>()),
    );
  }

  @override
  Map<String, FeatureRoute> get routes => {
        '/': (settings) => FeatureApp.buildRoute(
              settings: settings,
              builder: (_) => const HomePage(),
            ),
      };
}
