import 'package:inotes/core/contracts/feature_app.dart';
import 'package:inotes/core/di/locator.dart';
import 'package:inotes/features/auth/domain/usecases/clear_session_use_case.dart';
import 'package:inotes/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:inotes/features/home/presentation/cubit/home_cubit.dart';
import 'package:inotes/features/home/presentation/pages/home_page.dart';
import 'package:inotes/features/notes/domain/usecases/get_notes_use_case.dart';

class HomeFeature implements FeatureApp {
  @override
  Future<void> initializeDependencies() async {
    Locator.registerFactory<HomeCubit>(
      () => HomeCubit(
        Locator.get<GetNotesUseCase>(),
        Locator.get<GetCurrentSessionUseCase>(),
        Locator.get<ClearSessionUseCase>(),
      ),
    );
  }

  @override
  Map<String, FeatureRoute> get routes => {
    '/': (settings) => FeatureApp.buildRoute(settings: settings, builder: (_) => const HomePage()),
  };
}
