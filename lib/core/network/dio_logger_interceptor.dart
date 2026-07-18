import 'package:dio/dio.dart';

import '../utils/app_logger.dart';

class DioLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.i('➡️ ${options.method} ${options.uri}');
    AppLogger.d('Headers: ${options.headers}');

    if (options.queryParameters.isNotEmpty) {
      AppLogger.d('Query parameters: ${options.queryParameters}');
    }

    if (options.data != null) {
      AppLogger.d('Body: ${options.data}');
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final request = response.requestOptions;
    AppLogger.i('✅ ${response.statusCode} ${request.method} ${request.uri}');
    AppLogger.d('Response data: ${response.data}');

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = err.requestOptions;
    final statusCode = err.response?.statusCode;

    AppLogger.e(
      '❌ $statusCode ${request.method} ${request.uri}',
      error: err,
      stackTrace: err.stackTrace,
    );

    if (err.response?.data != null) {
      AppLogger.e('Error response: ${err.response?.data}');
    }

    super.onError(err, handler);
  }
}
