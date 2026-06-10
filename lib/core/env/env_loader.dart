abstract interface class EnvLoader {
  Future<void> load();
  String get(String key);
}
