import '../client_http.dart';

///Encapsulate response to help treatment
class CustomResponse<T> {
  bool hasError;
  T? result;
  ResponseError? error;

  CustomResponse._({
    required this.hasError,
    this.result,
    this.error,
  });

  /// Making sure parser existes for default return
  factory CustomResponse.ok(
    dynamic body,
    ParserFunctionMap<T>? parserMap,
    ParserFunctionList<T>? parserList,
  ) {
    assert(parserMap != null || parserList != null,
        'You must provide a parser for the response');

    if (parserMap == null && parserList == null) {
      throw Exception('Função para parsear a resposta não foi fornecida.');
    }
    if (body["result"] == null) {
      return CustomResponse._(hasError: false, result: body["result"]);
    }
    T? res = parserMap != null
        ? parserMap((body["result"] ?? body))
        : parserList!((body["result"] ?? body));
    return CustomResponse._(hasError: false, result: res);
  }

  factory CustomResponse.error(
      {String? description,
      String? technicalDescription,
      int? errorCode,
      ErrorType? errorType}) {
    return CustomResponse._(
      hasError: true,
      error: ResponseError.error(
          errorCode: errorCode,
          description: description,
          technicalDescription: technicalDescription,
          errorType: errorType),
    );
  }

  factory CustomResponse.sucess() {
    return CustomResponse._(hasError: false);
  }
}
