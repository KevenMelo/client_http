import 'package:client_http/src/custom_http.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:client_http/client_http.dart';

void main() {
  group('CustomHttp', () {
    late CustomHttp customHttp;

    setUp(() {
      customHttp = CustomHttp.instance();
    });

    test('setToken should set the token', () {
      const token = 'my_token';
      customHttp.setToken(token);
      expect(customHttp.token, token);
    });

    test('setToken should throw an exception if token is empty', () {
      expect(() => customHttp.setToken(''), throwsException);
    });

    test('removeToken should remove the token', () {
      customHttp.setToken('my_token');
      customHttp.removeToken();
      expect(customHttp.token, isNull);
    });

    test('get should make a GET request', () async {
      const url = 'https://example.com/api/data';
      final response = http.Response('{"ok": true}', 200);
      final httpClient = MockHttpClient(response);

      final customResponse = await customHttp.get<String>(
        url: url,
        headers: {'Content-Type': 'application/json'},
        parserMap: (json) => json['data'] as String,
        logger: (url, startTime,
            {end, time, response, body, error, stackTrace}) {},
        baseUrl: Environment.dev,
        logCall: true,
        logResponse: true,
        timeLimit: const Duration(seconds: 5),
      );

      expect(customResponse.hasError, true);
      expect(customResponse.result, isA<String>());
    });

    // Add more tests for other methods if needed
  });
}

class MockHttpClient extends http.BaseClient {
  final http.Response response;

  MockHttpClient(this.response);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(
      http.ByteStream.fromBytes(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
      request: request,
    );
  }
}
