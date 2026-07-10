import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? businessName,
    required String currency,
  });
  Future<void> logout();
  Future<void> verifyOtp({required String email, required String code});
  Future<void> resendOtp({required String email});
  Future<void> resetPassword({required String email});
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(@Named('dio') this._dio);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _dio.post('/api/login', data: {
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200) {
        return _parseAuthResponse(response.data);
      }
      throw AuthenticationException(response.data['message'] ?? 'Login failed');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? e.message ?? 'Server error',
      );
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? businessName,
    required String currency,
  }) async {
    try {
      final response = await _dio.post('/api/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'business_name': businessName,
        'currency': currency,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseAuthResponse(response.data);
      }
      throw ServerException(
        response.data['message'] ?? 'Registration failed',
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? e.message ?? 'Server error',
      );
    }
  }

  UserModel _parseAuthResponse(Map<String, dynamic> body) {
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) throw ServerException('Invalid response format');
    final userJson = data['user'] as Map<String, dynamic>? ?? {};
    final token = data['token'] as String?;
    final model = UserModel.fromJson(userJson);
    if (token != null) {
      return UserModel(
        id: model.id,
        name: model.name,
        email: model.email,
        businessName: model.businessName,
        currency: model.currency,
        token: token,
        subscriptionStatus: model.subscriptionStatus,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
      );
    }
    return model;
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('/api/logout');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Logout failed');
    }
  }

  @override
  Future<void> verifyOtp({required String email, required String code}) async {
    try {
      await _dio.post('/api/verify-otp', data: {
        'email': email,
        'code': code,
      });
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'OTP verification failed',
      );
    }
  }

  @override
  Future<void> resendOtp({required String email}) async {
    try {
      await _dio.post('/api/resend-otp', data: {'email': email});
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Resend OTP failed');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _dio.post('/api/reset-password', data: {'email': email});
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Password reset failed');
    }
  }
}
