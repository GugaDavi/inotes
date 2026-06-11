import 'package:inotes/services/local_storage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageImpl implements LocalStorage {
  const LocalStorageImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<String?> getString(String key) async => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) async => _prefs.setString(key, value);

  @override
  Future<void> remove(String key) async => _prefs.remove(key);
}
