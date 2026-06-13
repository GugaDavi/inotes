import 'package:go_router/go_router.dart';
import 'package:inotes/core/contracts/feature_app.dart';
import 'package:inotes/core/di/locator.dart';
import 'package:inotes/features/auth/domain/usecases/clear_session_use_case.dart';
import 'package:inotes/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:inotes/features/home/presentation/cubits/filter_cubit/filter_cubit.dart';
import 'package:inotes/features/home/presentation/cubits/home_cubit/home_cubit.dart';
import 'package:inotes/features/home/presentation/pages/home_page.dart';
import 'package:inotes/features/notes/domain/usecases/get_notes_use_case.dart';
import 'package:inotes/features/tags/domain/usecases/get_tags_use_case.dart';

class HomeFeature implements FeatureApp {
  @override
  Future<void> initializeDependencies() async {
    Locator.registerFactory<FilterCubit>(() => FilterCubit(Locator.get<GetTagsUseCase>()));
    Locator.registerFactory<HomeCubit>(
      () => HomeCubit(
        Locator.get<GetNotesUseCase>(),
        Locator.get<GetCurrentSessionUseCase>(),
        Locator.get<ClearSessionUseCase>(),
      ),
    );
  }

  @override
  List<RouteBase> get routes => [GoRoute(path: '/', builder: (context, state) => const HomePage())];
}
