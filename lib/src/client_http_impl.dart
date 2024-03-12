import 'package:client_http/client_http.dart';
import 'package:http/http.dart' as http;

class ClientImpl implements Client {
  @override
  void close() {
    http.Client().close();
  }

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) {
    return http.head(url, headers: headers);
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) {
    return http.read(url, headers: headers);
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) {
    return http.readBytes(url, headers: headers);
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return http.Client().send(request);
  }

  @override
  Future<Response> delete(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return http.delete(url, headers: headers, body: body, encoding: encoding);
  }

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) {
    return http.get(url, headers: headers);
  }

  @override
  Future<Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return http.patch(url, headers: headers, body: body, encoding: encoding);
  }

  @override
  Future<Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return http.post(url, headers: headers, body: body, encoding: encoding);
  }

  @override
  Future<Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return http.put(url, headers: headers, body: body, encoding: encoding);
  }
}
