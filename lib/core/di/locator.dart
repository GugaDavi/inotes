import 'package:get_it/get_it.dart';

final class Locator {
  Locator._();

  static final _container = GetIt.instance;

  static T get<T extends Object>() => _container.get<T>();

  static void registerFactory<T extends Object>(T Function() factory) {
    _container.registerFactory<T>(factory);
  }

  static void registerSingleton<T extends Object>(T instance) {
    _container.registerSingleton<T>(instance);
  }
}
