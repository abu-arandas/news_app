import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int _maxRetries;

  RetryInterceptor(this._dio, {int maxRetries = 2}) : _maxRetries = maxRetries;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err) && _maxRetries > 0) {
      for (var attempt = 1; attempt <= _maxRetries; attempt++) {
        await Future.delayed(Duration(seconds: attempt));
        try {
          final response = await _dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (_) {}
      }
    }
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.receiveTimeout ||
        (err.response != null && err.response!.statusCode! >= 500);
  }
}
