import 'package:client_http/client_http.dart';
import 'package:http/http.dart' as http;

class HttpClientImpl implements HttpClientInterface {
  @override
  Future delete(Uri uri, {options, body}) {
    return http.delete(uri, headers: options, body: body);
  }

  @override
  Future get(Uri uri, {options}) {
    return http.get(uri, headers: options);
  }

  @override
  Future post(Uri uri, {options, body}) {
    return http.post(uri, headers: options, body: body);
  }

  @override
  Future put(Uri uri, {options, body}) {
    return http.put(uri, headers: options, body: body);
  }

  @override
  Future patch(Uri uri, {options, body}) {
    return http.patch(uri, headers: options, body: body);
  }
}
