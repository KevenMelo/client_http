typedef ParserFunctionMap<T> = T Function(Map<String, dynamic> data);
typedef ParserFunctionList<T> = T Function(List data);

typedef LoggerFunction = Function(
  String url,
  DateTime start, {
  DateTime? end,
  Duration? time,
  Object? body,
  Object? response,
  Object? error,
  StackTrace? stackTrace,
});
