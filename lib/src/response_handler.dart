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

    return CustomResponse._(
        hasError: false,
        result: parserMap!((body["result"] ?? body)) ??
            parserList!(body["result"] ?? body));
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
}
