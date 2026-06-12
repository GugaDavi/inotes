import 'package:go_router/go_router.dart';
import 'package:inotes/core/contracts/feature_app.dart';
import 'package:inotes/core/di/locator.dart';
import 'package:inotes/features/tags/data/repositories/tags_repository_impl.dart';
import 'package:inotes/features/tags/domain/repositories/tags_repository.dart';
import 'package:inotes/features/tags/domain/usecases/get_tags_use_case.dart';
import 'package:inotes/services/firestore/firestore_service.dart';

class TagsFeature implements FeatureApp {
  @override
  Future<void> initializeDependencies() async {
    Locator.registerLazySingleton<TagsRepository>(() => TagsRepositoryImpl(Locator.get<FirestoreService>()));
    Locator.registerFactory<GetTagsUseCase>(() => GetTagsUseCase(Locator.get<TagsRepository>()));
  }

  @override
  List<RouteBase> get routes => [];
}
