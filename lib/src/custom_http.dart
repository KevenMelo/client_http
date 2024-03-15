import 'package:client_http/client_http.dart';

import 'client_http_impl.dart';

/// classe singleton para realizar às requisições http

class CustomHttp {
  CustomHttp._internal(Client client, [bool? retry, String? baseUrl])
      : _client = client,
        baseUrl = baseUrl ??
            (kDebugMode ? Environment.dev.url : Environment.production.url),
        _retry = retry ?? true;

  final Client _client;
  bool _retry = false;

  String baseUrl;

  static final CustomHttp _instance = CustomHttp._internal(
    ClientImpl(),
  );

  /// Construtor factory para retornar a instância da classe,
  /// podendo ser passado um client customizado,
  /// que implemente a interface [Client].
  /// Caso não seja passado um client, será usado um client http padrão.

  factory CustomHttp.instance({Client? client}) {
    return client != null ? CustomHttp._internal(client) : _instance;
  }

  String? _token;

  /// Método para setar o token de autenticação.
  /// Lança uma exceção caso o token seja vazio.
  void setToken(String token) {
    if (token.isNotEmpty) {
      _token = token;
      return;
    }
    throw Exception("Token não pode ser vazio");
  }

  /// Método para remover o token de autenticação.

  void removeToken() {
    _token = null;
  }

  String? get token => _token;

  /// Método para realizar uma requisição do tipo GET.
  /// Recebe como parâmetros:
  /// - [url] - String - url da requisição
  /// - [headers] - Map<String, String> - cabeçalho da requisição
  /// - [parserMap] - ParserFunctionMap<T> - função para parsear o resultado da requisição
  /// - [parserList] - ParserFunctionList<T> - função para parsear o resultado da requisição
  /// - [logger] - LoggerFunction - função para logar a requisição
  /// - [baseUrl] - Environment - ambiente da requisição
  /// - [logCall] - bool - flag para logar a requisição
  /// - [logResponse] - bool - flag para logar a resposta da requisição
  /// - [timeLimit] - Duration - tempo limite para a requisição
  /// Retorna um [Future<CustomResponse<T>>] com o resultado da requisição.
  /// Caso ocorra algum erro, será retornado um [CustomResponse.error].
  /// Caso a requisição seja bem sucedida, será retornado um [CustomResponse.ok].

  Future<CustomResponse<T>> get<T>({
    required String url,
    Map<String, String>? headers,
    ParserFunctionMap<T>? parserMap,
    ParserFunctionList<T>? parserList,
    LoggerFunction? logger,
    Environment? customBaseUrl,
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

      final response = await _client
          .get(
            Uri.parse(
                "${customBaseUrl != null ? customBaseUrl.url : baseUrl}$url"),
            headers: headers,
          )
          .timeout(timeLimit);

      if (response.headers.containsKey('token')) {
        final token = response.headers['token'];
        if (token != null) {
          setToken(token);
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
      final body = json.decode(response.body);
      if ((body["ok"] ?? false) || response.statusCode < 400) {
        return CustomResponse.ok(
          body,
          parserMap,
          parserList,
        );
      } else {
        return CustomResponse.error(
          description: body["description"] ?? body,
          technicalDescription: body["technicalDescription"] ?? body,
          errorCode: response.statusCode,
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
        errorCode: 408,
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

      // if (_retry) {
      //   get(
      //       url: url,
      //       headers: headers,
      //       parserMap: parserMap,
      //       parserList: parserList);
      // }
      return CustomResponse.error(
        description: e.toString(),
        errorCode: 500,
        errorType: ErrorType.applicationError,
      );
    }
  }

  /// Método para realizar uma requisição do tipo POST.
  /// Recebe como parâmetros:
  /// - [url] - String - url da requisição
  /// - [headers] - Map<String, String> - cabeçalho da requisição
  /// - [parserMap] - ParserFunctionMap<T> - função para parsear o resultado da requisição
  /// - [parserList] - ParserFunctionList<T> - função para parsear o resultado da requisição
  /// - [logger] - LoggerFunction - função para logar a requisição
  /// - [baseUrl] - Environment - ambiente da requisição
  /// - [logCall] - bool - flag para logar a requisição
  /// - [logResponse] - bool - flag para logar a resposta da requisição
  /// - [timeLimit] - Duration - tempo limite para a requisição
  /// - [bodyReq] - Map - corpo da requisição
  /// Retorna um [Future<CustomResponse<T>>] com o resultado da requisição.
  /// Caso ocorra algum erro, será retornado um [CustomResponse.error].
  /// Caso a requisição seja bem sucedida, será retornado um [CustomResponse.ok].

  Future<CustomResponse<T>> post<T>({
    required String url,
    Map<String, String>? headers,
    ParserFunctionMap<T>? parserMap,
    ParserFunctionList<T>? parserList,
    LoggerFunction? logger,
    Environment? customBaseUrl,
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

      final response = await _client
          .post(
            Uri.parse(
                "${customBaseUrl != null ? customBaseUrl.url : baseUrl}$url"),
            headers: headers,
            body: jsonEncode(bodyReq),
          )
          .timeout(timeLimit);
      if (response.headers.containsKey('token')) {
        final token = response.headers['token'];
        if (token != null) {
          setToken(token);
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

  /// Método para realizar uma requisição do tipo PUT.
  /// Recebe como parâmetros:
  ///   - [url] - String - url da requisição
  /// - [headers] - Map<String, String> - cabeçalho da requisição
  /// - [parserMap] - ParserFunctionMap<T> - função para parsear o resultado da requisição
  /// - [parserList] - ParserFunctionList<T> - função para parsear o resultado da requisição
  ///  - [logger] - LoggerFunction - função para logar a requisição
  /// - [baseUrl] - Environment - ambiente da requisição
  /// - [logCall] - bool - flag para logar a requisição
  /// - [logResponse] - bool - flag para logar a resposta da requisição
  /// - [timeLimit] - Duration - tempo limite para a requisição
  /// - [bodyReq] - Map - corpo da requisição
  /// Retorna um [Future<CustomResponse<T>>] com o resultado da requisição.
  /// Caso ocorra algum erro, será retornado um [CustomResponse.error].
  /// Caso a requisição seja bem sucedida, será retornado um [CustomResponse.ok].

  Future<CustomResponse<T>> put<T>({
    required String url,
    Map<String, String>? headers,
    ParserFunctionMap<T>? parserMap,
    ParserFunctionList<T>? parserList,
    LoggerFunction? logger,
    Environment? customBaseUrl,
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

      final response = await _client
          .post(
            Uri.parse(
                "${customBaseUrl != null ? customBaseUrl.url : baseUrl}$url"),
            headers: headers,
            body: jsonEncode(bodyReq),
          )
          .timeout(timeLimit);
      if (response.headers.containsKey('token')) {
        final token = response.headers['token'];
        if (token != null) {
          setToken(token);
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

  /// Método para realizar uma requisição do tipo PATCH.
  /// Recebe como parâmetros:
  /// - [url] - String - url da requisição
  /// - [headers] - Map<String, String> - cabeçalho da requisição
  ///  - [parserMap] - ParserFunctionMap<T> - função para parsear o resultado da requisição
  /// - [parserList] - ParserFunctionList<T> - função para parsear o resultado da requisição
  /// - [logger] - LoggerFunction - função para logar a requisição
  /// - [baseUrl] - Environment - ambiente da requisição
  /// - [logCall] - bool - flag para logar a requisição
  /// - [logResponse] - bool - flag para logar a resposta da requisição]
  ///  - [timeLimit] - Duration - tempo limite para a requisição
  /// - [bodyReq] - Map - corpo da requisição
  /// Retorna um [Future<CustomResponse<T>>] com o resultado da requisição.
  /// Caso ocorra algum erro, será retornado um [CustomResponse.error].
  /// Caso a requisição seja bem sucedida, será retornado um [CustomResponse.ok].

  Future<CustomResponse<T>> patch<T>({
    required String url,
    Map<String, String>? headers,
    ParserFunctionMap<T>? parserMap,
    ParserFunctionList<T>? parserList,
    LoggerFunction? logger,
    Environment? customBaseUrl,
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

      final response = await _client
          .post(
            Uri.parse(
                "${customBaseUrl != null ? customBaseUrl.url : baseUrl}$url"),
            headers: headers,
            body: jsonEncode(bodyReq),
          )
          .timeout(timeLimit);
      if (response.headers.containsKey('token')) {
        final token = response.headers['token'];
        if (token != null) {
          setToken(token);
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

  /// Método para realizar uma requisição do tipo DELETE.
  /// Recebe como parâmetros:
  /// - [url] - String - url da requisição
  /// - [headers] - Map<String, String> - cabeçalho da requisição
  /// - [parserMap] - ParserFunctionMap<T> - função para parsear o resultado da requisição
  ///   - [parserList] - ParserFunctionList<T> - função para parsear o resultado da requisição
  /// - [logger] - LoggerFunction - função para logar a requisição
  /// - [baseUrl] - Environment - ambiente da requisição
  /// - [logCall] - bool - flag para logar a requisição
  /// - [logResponse] - bool - flag para logar a resposta da requisição
  /// - [timeLimit] - Duration - tempo limite para a requisição
  /// - [bodyReq] - Map - corpo da requisição
  /// Retorna um [Future<CustomResponse<T>>] com o resultado da requisição.
  /// Caso ocorra algum erro, será retornado um [CustomResponse.error].
  /// Caso a requisição seja bem sucedida, será retornado um [CustomResponse.ok].

  Future<CustomResponse<T>> delete<T>({
    required String url,
    Map<String, String>? headers,
    ParserFunctionMap<T>? parserMap,
    ParserFunctionList<T>? parserList,
    LoggerFunction? logger,
    Environment? customBaseUrl,
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

      final response = await _client
          .post(
            Uri.parse(
                "${customBaseUrl != null ? customBaseUrl.url : baseUrl}$url"),
            headers: headers,
            body: jsonEncode(bodyReq),
          )
          .timeout(timeLimit);
      if (response.headers.containsKey('token')) {
        final token = response.headers['token'];
        if (token != null) {
          setToken(token);
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
