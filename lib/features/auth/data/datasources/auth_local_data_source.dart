import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel userToCache);
  Future<UserModel?> getCachedUser();
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> clearAuthData();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheUser(UserModel userToCache) async {
    await secureStorage.write(
        key: 'cached_user', value: json.encode(userToCache.toJson()));
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final jsonString = await secureStorage.read(key: 'cached_user');
    if (jsonString != null) {
      return UserModel.fromJson(json.decode(jsonString));
    }
    return null;
  }

  @override
  Future<void> cacheToken(String token) async {
    await secureStorage.write(key: 'auth_token', value: token);
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: 'auth_token');
  }

  @override
  Future<void> clearAuthData() async {
    await secureStorage.delete(key: 'cached_user');
    await secureStorage.delete(key: 'auth_token');
  }
}
