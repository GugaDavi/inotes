import 'package:go_router/go_router.dart';
import 'package:inotes/core/contracts/feature_app.dart';
import 'package:inotes/core/di/locator.dart';
import 'package:inotes/features/auth/data/repositories/session_repository_impl.dart';
import 'package:inotes/features/auth/domain/repositories/session_repository.dart';
import 'package:inotes/features/auth/domain/usecases/clear_session_use_case.dart';
import 'package:inotes/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:inotes/features/auth/domain/usecases/start_session_use_case.dart';
import 'package:inotes/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:inotes/features/auth/presentation/pages/auth_page.dart';
import 'package:inotes/services/local_storage/local_storage.dart';

class AuthFeature implements FeatureApp {
  @override
  Future<void> initializeDependencies() async {
    Locator.registerFactory<SessionRepository>(() => SessionRepositoryImpl(Locator.get<LocalStorage>()));
    Locator.registerFactory<GetCurrentSessionUseCase>(() => GetCurrentSessionUseCase(Locator.get<SessionRepository>()));
    Locator.registerFactory<StartSessionUseCase>(() => StartSessionUseCase(Locator.get<SessionRepository>()));
    Locator.registerFactory<ClearSessionUseCase>(() => ClearSessionUseCase(Locator.get<SessionRepository>()));
    Locator.registerFactory<AuthCubit>(
      () => AuthCubit(Locator.get<GetCurrentSessionUseCase>(), Locator.get<StartSessionUseCase>()),
    );
  }

  @override
  List<RouteBase> get routes => [GoRoute(path: '/auth', builder: (context, state) => const AuthPage())];
}
