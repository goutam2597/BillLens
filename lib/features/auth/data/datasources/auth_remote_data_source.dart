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
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1500));

      if (email.isEmpty || password.isEmpty) {
        throw AuthenticationException('Invalid email or password');
      }

      // Mock user response
      return UserModel(
        id: 'user_123',
        name: 'Mock User',
        email: email,
        currency: 'USD',
        subscriptionStatus: 'free',
        token: 'mock_jwt_token_12345',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw ServerException(e.toString());
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
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1500));

      // Mock user response
      return UserModel(
        id: 'user_123',
        name: name,
        email: email,
        businessName: businessName,
        currency: currency,
        subscriptionStatus: 'free',
        token: 'mock_jwt_token_12345',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
