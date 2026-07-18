import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'auth_interceptor.dart';
import 'dio_logger_interceptor.dart';

@module
abstract class NetworkModule {
  @Named('dio')
  @singleton
  Dio dio(AuthInterceptor authInterceptor) {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://192.168.0.187/billlens/billlens_backend/public',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(authInterceptor);
    dio.interceptors.add(DioLoggerInterceptor());

    return dio;
  }
}
