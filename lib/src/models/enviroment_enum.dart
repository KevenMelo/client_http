enum Environment {
  dev("https://dev.carajaslabs.com.br"),
  homolog("https://homolog.carajaslabs.com.br"),
  production("https://carajaslabs.com.br"),
  custom("");

  const Environment(this.url);

  final String url;
}
