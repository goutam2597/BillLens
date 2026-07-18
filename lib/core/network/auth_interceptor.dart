import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../auth/auth_session_manager.dart';

@singleton
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(key: 'auth_token');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      // The backend rejected the session. Clear local credentials and signal
      // the app to force a logout so the user is redirected to login.
      _clearCredentials();
      AuthSessionManager.instance.invalidate();
    }
    return handler.next(err);
  }

  void _clearCredentials() {
    _secureStorage.delete(key: 'auth_token');
    _secureStorage.delete(key: 'cached_user');
  }
}
