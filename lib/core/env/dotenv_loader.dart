import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inotes/core/env/env_loader.dart';

class DotenvLoader implements EnvLoader {
  DotenvLoader(this._env);

  final DotEnv _env;

  @override
  Future<void> load() => _env.load(fileName: '.env');

  @override
  String get(String key) {
    final value = _env.maybeGet(key);
    if (value == null) {
      throw ArgumentError('Environment variable "$key" not found.');
    }
    return value;
  }
}
