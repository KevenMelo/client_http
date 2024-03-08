import 'package:client_http/client_http.dart';
import 'package:http/http.dart' as http;

class CustomHttp {
  CustomHttp._internal();

  static final CustomHttp _instance = CustomHttp._internal();

  factory CustomHttp.instance() => _instance;

  String? _token;

  void setToken(String token) {
    if (token.isNotEmpty) {
      _token = token;
      return;
    }
    throw Exception("Token não pode ser vazio");
  }

  void removeToken() {
    _token = null;
  }

  String? get token => _token;

  Future<CustomResponse<T>> get<T>({
    required String url,
    Map<String, String>? headers,
    ParserFunctionMap<T>? parserMap,
    ParserFunctionList<T>? parserList,
    LoggerFunction? logger,
    Environment baseUrl = kDebugMode ? Environment.dev : Environment.production,
    bool logCall = false,
    bool logResponse = false,
    Duration timeLimit = const Duration(seconds: 275),
  }) async {
    assert(parserMap != null || parserList != null,
        "Necessário informar um parser para a requisição");

    final startTime = DateTime.now();
    try {
      if (headers == null) {
        headers = {HttpHeaders.authorizationHeader: "Bearer $_token"};
      } else {
        headers.putIfAbsent(
            HttpHeaders.authorizationHeader, () => "Bearer $_token");
      }
      if (logCall && logger != null) logger(url, startTime);

      final response = await http
          .get(
            Uri.parse("${baseUrl.url}$url"),
            headers: headers,
          )
          .timeout(timeLimit);

      if (response.headers.containsKey('token')) {
        final token = response.headers['token'];
        if (token != null) {
          _token = token;
        }
      }

      if (logResponse && logger != null) {
        logger(
          url,
          startTime,
          end: DateTime.now(),
          time: startTime.difference(DateTime.now()),
          response: response.body,
        );
      }
      final body = json.decode(utf8.decode(response.bodyBytes));
      if ((body["ok"] ?? false) || response.statusCode < 400) {
        return CustomResponse.ok(
          body,
          parserMap,
          parserList,
        );
      } else {
        return CustomResponse.error(
          description: body["description"],
          technicalDescription: body["technicalDescription"],
          errorCode: body["errorCode"],
          errorType: ErrorType.requestError,
        );
      }
    } on TimeoutException catch (e, trace) {
      if (logger != null) {
        logger(
          url,
          startTime,
          end: DateTime.now(),
          time: startTime.difference(DateTime.now()),
          error: e,
          stackTrace: trace,
        );
      }
      return CustomResponse.error(
        description: 'Tempo de requisição excedido',
        errorType: ErrorType.timeOut,
      );
    } catch (e, trace) {
      if (logger != null) {
        logger(
          url,
          startTime,
          end: DateTime.now(),
          time: startTime.difference(DateTime.now()),
          error: e,
          stackTrace: trace,
        );
      }
      return CustomResponse.error(
        description: e.toString(),
        errorType: ErrorType.applicationError,
      );
    }
  }

  Future<CustomResponse<T>> post<T>({
    required String url,
    Map<String, String>? headers,
    ParserFunctionMap<T>? parserMap,
    ParserFunctionList<T>? parserList,
    LoggerFunction? logger,
    Environment baseUrl = kDebugMode ? Environment.dev : Environment.production,
    bool logCall = false,
    bool logResponse = false,
    Duration timeLimit = const Duration(seconds: 275),
    Map? bodyReq,
  }) async {
    final startTime = DateTime.now();

    try {
      // headers = {...?this.headers, ...?headers};
      if (headers == null) {
        headers = {HttpHeaders.authorizationHeader: "Bearer $_token"};
      } else {
        headers.putIfAbsent(
            HttpHeaders.authorizationHeader, () => "Bearer $_token");
      }
      if (logCall && logger != null) logger(url, startTime, body: bodyReq);

      final response = await http
          .post(
            Uri.parse("${baseUrl.url}$url"),
            headers: headers,
            body: jsonEncode(bodyReq),
          )
          .timeout(timeLimit);
      if (response.headers.containsKey('token')) {
        final token = response.headers['token'];
        if (token != null) {
          _token = token;
        }
      }
      if (logResponse && logger != null) {
        logger(
          url,
          startTime,
          end: DateTime.now(),
          time: startTime.difference(DateTime.now()),
          response: response.body,
          body: bodyReq,
        );
      }

      final body = json.decode(utf8.decode(response.bodyBytes));
      if ((body["ok"] ?? false) || response.statusCode < 400) {
        return CustomResponse.ok(
          body,
          parserMap,
          parserList,
        );
      } else {
        return CustomResponse.error(
          description: body["description"],
          technicalDescription: body["technicalDescription"],
          errorCode: body["errorCode"],
          errorType: ErrorType.requestError,
        );
      }
    } on TimeoutException catch (e, trace) {
      if (logger != null) {
        logger(
          url,
          startTime,
          end: DateTime.now(),
          time: startTime.difference(DateTime.now()),
          error: e,
          stackTrace: trace,
        );
      }
      return CustomResponse.error(
        description: 'Tempo de requisição excedido',
        errorType: ErrorType.timeOut,
      );
    } catch (e, trace) {
      if (logger != null) {
        logger(
          url,
          startTime,
          end: DateTime.now(),
          time: startTime.difference(DateTime.now()),
          error: e,
          stackTrace: trace,
        );
      }
      return CustomResponse.error(
        description: e.toString(),
        errorType: ErrorType.applicationError,
      );
      //  responseErrorCatcher(message: e.toString(), tracer: trace);
    }
  }

  Future<CustomResponse<T>> put<T>({
    required String url,
    Map<String, String>? headers,
    ParserFunctionMap<T>? parserMap,
    ParserFunctionList<T>? parserList,
    LoggerFunction? logger,
    Environment baseUrl = kDebugMode ? Environment.dev : Environment.production,
    bool logCall = false,
    bool logResponse = false,
    Duration timeLimit = const Duration(seconds: 275),
    Object? bodyReq,
  }) async {
    final startTime = DateTime.now();

    try {
      // headers = {...?this.headers, ...?headers};
      if (headers == null) {
        headers = {HttpHeaders.authorizationHeader: "Bearer $_token"};
      } else {
        headers.putIfAbsent(
            HttpHeaders.authorizationHeader, () => "Bearer $_token");
      }
      if (logCall && logger != null) logger(url, startTime, body: bodyReq);

      final response = await http
          .post(
            Uri.parse("${baseUrl.url}$url"),
            headers: headers,
            body: jsonEncode(bodyReq),
          )
          .timeout(timeLimit);
      if (response.headers.containsKey('token')) {
        final token = response.headers['token'];
        if (token != null) {
          _token = token;
        }
      }
      if (logResponse && logger != null) {
        logger(
          url,
          startTime,
          end: DateTime.now(),
          time: startTime.difference(DateTime.now()),
          response: response.body,
          body: bodyReq,
        );
      }

      final body = json.decode(utf8.decode(response.bodyBytes));
      if ((body["ok"] ?? false) || response.statusCode < 400) {
        return CustomResponse.ok(
          body,
          parserMap,
          parserList,
        );
      } else {
        return CustomResponse.error(
          description: body["description"],
          technicalDescription: body["technicalDescription"],
          errorCode: body["errorCode"],
          errorType: ErrorType.requestError,
        );
      }
    } on TimeoutException catch (e, trace) {
      if (logger != null) {
        logger(
          url,
          startTime,
          end: DateTime.now(),
          time: startTime.difference(DateTime.now()),
          error: e,
          stackTrace: trace,
        );
      }
      return CustomResponse.error(
        description: 'Tempo de requisição excedido',
        errorType: ErrorType.timeOut,
      );
    } catch (e, trace) {
      if (logger != null) {
        logger(
          url,
          startTime,
          end: DateTime.now(),
          time: startTime.difference(DateTime.now()),
          error: e,
          stackTrace: trace,
        );
      }
      return CustomResponse.error(
        description: e.toString(),
        errorType: ErrorType.applicationError,
      );
      //  responseErrorCatcher(message: e.toString(), tracer: trace);
    }
  }

  Future<CustomResponse<T>> patch<T>({
    required String url,
    Map<String, String>? headers,
    ParserFunctionMap<T>? parserMap,
    ParserFunctionList<T>? parserList,
    LoggerFunction? logger,
    Environment baseUrl = kDebugMode ? Environment.dev : Environment.production,
    bool logCall = false,
    bool logResponse = false,
    Duration timeLimit = const Duration(seconds: 275),
    Object? bodyReq,
  }) async {
    final startTime = DateTime.now();

    try {
      // headers = {...?this.headers, ...?headers};
      if (headers == null) {
        headers = {HttpHeaders.authorizationHeader: "Bearer $_token"};
      } else {
        headers.putIfAbsent(
            HttpHeaders.authorizationHeader, () => "Bearer $_token");
      }
      if (logCall && logger != null) logger(url, startTime, body: bodyReq);

      final response = await http
          .post(
            Uri.parse("${baseUrl.url}$url"),
            headers: headers,
            body: jsonEncode(bodyReq),
          )
          .timeout(timeLimit);
      if (response.headers.containsKey('token')) {
        final token = response.headers['token'];
        if (token != null) {
          _token = token;
        }
      }
      if (logResponse && logger != null) {
        logger(
          url,
          startTime,
          end: DateTime.now(),
          time: startTime.difference(DateTime.now()),
          response: response.body,
          body: bodyReq,
        );
      }

      final body = json.decode(utf8.decode(response.bodyBytes));
      if ((body["ok"] ?? false) || response.statusCode < 400) {
        return CustomResponse.ok(
          body,
          parserMap,
          parserList,
        );
      } else {
        return CustomResponse.error(
          description: body["description"],
          technicalDescription: body["technicalDescription"],
          errorCode: body["errorCode"],
          errorType: ErrorType.requestError,
        );
      }
    } on TimeoutException catch (e, trace) {
      if (logger != null) {
        logger(
          url,
          startTime,
          end: DateTime.now(),
          time: startTime.difference(DateTime.now()),
          error: e,
          stackTrace: trace,
        );
      }
      return CustomResponse.error(
        description: 'Tempo de requisição excedido',
        errorType: ErrorType.timeOut,
      );
    } catch (e, trace) {
      if (logger != null) {
        logger(
          url,
          startTime,
          end: DateTime.now(),
          time: startTime.difference(DateTime.now()),
          error: e,
          stackTrace: trace,
        );
      }
      return CustomResponse.error(
        description: e.toString(),
        errorType: ErrorType.applicationError,
      );
    }
  }

  Future<CustomResponse<T>> delete<T>({
    required String url,
    Map<String, String>? headers,
    ParserFunctionMap<T>? parserMap,
    ParserFunctionList<T>? parserList,
    LoggerFunction? logger,
    Environment baseUrl = kDebugMode ? Environment.dev : Environment.production,
    bool logCall = false,
    bool logResponse = false,
    Duration timeLimit = const Duration(seconds: 275),
    Object? bodyReq,
  }) async {
    final startTime = DateTime.now();

    try {
      // headers = {...?this.headers, ...?headers};
      if (headers == null) {
        headers = {HttpHeaders.authorizationHeader: "Bearer $_token"};
      } else {
        headers.putIfAbsent(
            HttpHeaders.authorizationHeader, () => "Bearer $_token");
      }
      if (logCall && logger != null) logger(url, startTime, body: bodyReq);

      final response = await http
          .post(
            Uri.parse("${baseUrl.url}$url"),
            headers: headers,
            body: jsonEncode(bodyReq),
          )
          .timeout(timeLimit);
      if (response.headers.containsKey('token')) {
        final token = response.headers['token'];
        if (token != null) {
          _token = token;
        }
      }
      if (logResponse && logger != null) {
        logger(
          url,
          startTime,
          end: DateTime.now(),
          time: startTime.difference(DateTime.now()),
          response: response.body,
          body: bodyReq,
        );
      }

      final body = json.decode(utf8.decode(response.bodyBytes));
      if ((body["ok"] ?? false) || response.statusCode < 400) {
        return CustomResponse.ok(
          body,
          parserMap,
          parserList,
        );
      } else {
        return CustomResponse.error(
          description: body["description"],
          technicalDescription: body["technicalDescription"],
          errorCode: body["errorCode"],
          errorType: ErrorType.requestError,
        );
      }
    } on TimeoutException catch (e, trace) {
      if (logger != null) {
        logger(
          url,
          startTime,
          end: DateTime.now(),
          time: startTime.difference(DateTime.now()),
          error: e,
          stackTrace: trace,
        );
      }
      return CustomResponse.error(
        description: 'Tempo de requisição excedido',
        errorType: ErrorType.timeOut,
      );
    } catch (e, trace) {
      if (logger != null) {
        logger(
          url,
          startTime,
          end: DateTime.now(),
          time: startTime.difference(DateTime.now()),
          error: e,
          stackTrace: trace,
        );
      }
      return CustomResponse.error(
        description: e.toString(),
        errorType: ErrorType.applicationError,
      );
    }
  }
}
