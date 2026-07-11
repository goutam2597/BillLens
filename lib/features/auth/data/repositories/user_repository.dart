import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../datasources/auth_local_data_source.dart';
import '../models/user_model.dart';

abstract class UserRepository {
  Future<Either<Failure, UserModel>> updateProfile({
    required String userId,
    String? name,
    String? firstName,
    String? lastName,
    String? phone,
    String? businessName,
    String? address,
    String? city,
    String? state,
    String? zip,
    String? currency,
  });

  Future<Either<Failure, String>> uploadAvatar(
      {required String userId, required String filePath});

  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class UserRepositoryImpl implements UserRepository {
  final Dio _dio;
  final AuthLocalDataSource _localDataSource;

  UserRepositoryImpl({
    @Named('dio') required Dio dio,
    required AuthLocalDataSource localDataSource,
  })  : _dio = dio,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, UserModel>> updateProfile({
    required String userId,
    String? name,
    String? firstName,
    String? lastName,
    String? phone,
    String? businessName,
    String? address,
    String? city,
    String? state,
    String? zip,
    String? currency,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (phone != null) data['phone'] = phone;
      if (businessName != null) data['business_name'] = businessName;
      if (address != null) data['address'] = address;
      if (city != null) data['city'] = city;
      if (state != null) data['state'] = state;
      if (zip != null) data['zip'] = zip;
      if (currency != null) data['currency'] = currency;

      final response = await _dio.put('/api/profile', data: data);
      if (response.statusCode == 200) {
        final json = response.data['data'] as Map<String, dynamic>;
        final updatedUser = UserModel.fromJson(json);
        // Persist the updated user so CheckAuthStatus returns fresh data
        await _localDataSource.cacheUser(updatedUser);
        return Right(updatedUser);
      }
      throw ServerException(response.data['message'] ?? 'Update failed');
    } on DioException catch (e) {
      final msg = e.response?.data is Map ? e.response?.data['message'] : null;
      return Left(ServerFailure(msg ?? e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });
      final response =
          await _dio.post('/api/upload-avatar', data: formData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        return Right(data['avatar_url'] as String);
      }
      throw ServerException(response.data['message'] ?? 'Upload failed');
    } on DioException catch (e) {
      final msg = e.response?.data is Map ? e.response?.data['message'] : null;
      return Left(ServerFailure(msg ?? e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post('/api/change-password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
      if (response.statusCode == 200) {
        return const Right(null);
      }
      throw ServerException(response.data['message'] ?? 'Change failed');
    } on DioException catch (e) {
      final msg = e.response?.data is Map ? e.response?.data['message'] : null;
      return Left(ServerFailure(msg ?? e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
