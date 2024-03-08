///Model for errors
///Custom field with dynamic type for specific treatment
class ResponseError {
  int? errorCode;
  String? description;
  String? technicalDescription;
  ErrorType? errorType;

  ResponseError({
    this.errorCode,
    this.description,
    this.technicalDescription,
    this.errorType,
  });

  ///Factory to create a default error
  ///Change for your need
  ///Default error is applicationError
  factory ResponseError.error({
    String? description,
    String? technicalDescription,
    int? errorCode,
    ErrorType? errorType,
  }) {
    return ResponseError(
      errorCode: errorCode,
      description: description ?? 'Erro Interno',
      technicalDescription: technicalDescription ?? 'Erro interno desconhecido',
      errorType: errorType ?? ErrorType.applicationError,
    );
  }

  ///Parsing data from json to model
  ///Using default error model
  ///Change for your need
  factory ResponseError.fromJson(Map<String, dynamic> json) {
    return ResponseError(
      errorCode: json['error_code'] as int?,
      description: json['description'] as String? ?? 'Erro desconhecido',
      technicalDescription:
          json['technical_description'] as String? ?? 'Sem descrição técnica',
      errorType: json['errorType'] as ErrorType? ?? ErrorType.applicationError,
    );
  }

  ///Parsing data back to json
  ///To help prints
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['technical_description'] = technicalDescription;
    data['errorType'] = errorType;
    return data;
  }
}

enum ErrorType {
  timeOut,
  requestError,
  connectionError,
  applicationError,
}
