import 'package:flutter/foundation.dart';

class AuthStateNotifier extends ChangeNotifier {
  AuthStateNotifier({required this._isAuthenticated});

  bool _isAuthenticated;
  bool get isAuthenticated => _isAuthenticated;

  void setAuthenticated(bool value) {
    if (_isAuthenticated == value) return;
    _isAuthenticated = value;
    notifyListeners();
  }
}
