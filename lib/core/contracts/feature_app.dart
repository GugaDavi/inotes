import 'package:go_router/go_router.dart';

abstract class FeatureApp {
  Future<void> initializeDependencies();
  List<RouteBase> get routes;
}
