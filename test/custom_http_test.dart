import 'package:client_http/src/custom_http.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:client_http/client_http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'custom_http_test.mocks.dart';

// @GenerateMocks([HttpClientInterface])
@GenerateNiceMocks([
  MockSpec<Client>(),
])
void main() {
  group('CustomHttp', () {
    late CustomHttp customHttp;
    late MockClient client;
    setUp(() {
      client = MockClient();
      customHttp = CustomHttp.instance(client: client);
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

    test('get should make a sucess GET request', () async {
      String? token;
      Response response = http.Response('{"result": "my_data"}', 200);
      when(client.get(Uri.parse('${Environment.dev.url}/test'), headers: {
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token'
      })).thenAnswer((_) async => response);
      final customResponse = await customHttp.get<String>(
        url: '/test',
        headers: {'Content-Type': 'application/json'},
        parserMap: (json) => json["result"] as String,
        logger: (url, startTime,
            {end, time, response, body, error, stackTrace}) {},
        customBaseUrl: Environment.dev,
        logCall: true,
        logResponse: true,
        timeLimit: const Duration(seconds: 5),
      );

      expect(customResponse.hasError, false);
      expect(customResponse.result, isA<String>());
    });

    test('get should make a error GET request', () async {
      String? token;
      Response response = http.Response('error generic', 400);
      when(client.get(Uri.parse('${Environment.dev.url}/test'), headers: {
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token'
      })).thenAnswer((_) async => response);
      final customResponse = await customHttp.get<String>(
        url: '/test',
        headers: {'Content-Type': 'application/json'},
        parserMap: (json) => json['error'] as String,
        logger: (url, startTime,
            {end, time, response, body, error, stackTrace}) {},
        customBaseUrl: Environment.dev,
        logCall: true,
        logResponse: true,
        timeLimit: const Duration(seconds: 5),
      );

      expect(customResponse.hasError, true);
      expect(customResponse.result, null);
    });
  });
}
