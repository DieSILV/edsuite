enum AppEnvironment { dev, staging, prod }

class Environment {
  static final Environment _instance = Environment._internal();

  factory Environment() {
    return _instance;
  }

  Environment._internal();

  AppEnvironment get currentEnvironment {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    return AppEnvironment.values.firstWhere(
      (e) => e.toString().split('.').last == env,
    );
  }

  bool get enableLogging => currentEnvironment != AppEnvironment.prod;

  String get baseUrl => const String.fromEnvironment('BASE_URL');

  void checkEnvVariables() {
    if (baseUrl.isEmpty) {
      throw AssertionError('BASE_URL environment variable is not defined');
    }
  }
}
