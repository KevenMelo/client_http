enum Environment {
  dev("https://dev.carajaslabs.com.br"),
  homolog("https://homolog.carajaslabs.com.br"),
  production("https://carajaslabs.com.br"),
  custom("");

  const Environment(this.url);
  final String url;
}

class EnvironmentHelper {
  final String value;

  const EnvironmentHelper(this.value);

  Environment get environment {
    for (var env in Environment.values) {
      if (env.url == value) {
        return env;
      }
    }
    return Environment.custom;
  }
}

extension EnvironmentExtension on Environment {
  String get url {
    switch (this) {
      case Environment.dev:
        return "https://dev.carajaslabs.com.br";
      case Environment.homolog:
        return "https://homolog.carajaslabs.com.br";
      case Environment.production:
        return "https://carajaslabs.com.br";
      default:
        return this.url;
    }
  }
}
