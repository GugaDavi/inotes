import 'package:flutter/cupertino.dart';

typedef FeatureRoute<T> = PageRoute<T> Function(RouteSettings?);

abstract class FeatureApp {
  Future<void> initializeDependencies();
  Map<String, FeatureRoute> get routes;

  static CupertinoPageRoute<T> buildRoute<T>({
    required WidgetBuilder builder,
    required RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) => CupertinoPageRoute<T>(
    builder: builder,
    settings: settings,
    maintainState: maintainState,
    fullscreenDialog: fullscreenDialog,
  );
}
