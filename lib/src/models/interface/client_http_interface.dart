abstract interface class HttpClientInterface {
  Future<dynamic> get(Uri uri, {options});
  Future<dynamic> post(Uri uri, {options, body});
  Future<dynamic> put(Uri uri, {options, body});
  Future<dynamic> patch(Uri uri, {options, body});
  Future<dynamic> delete(Uri uri, {options, body});
}
