import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';

abstract class AccountDeletionRemoteDataSource {
  Future<Map<String, dynamic>> requestDeletion({String? reason});
  Future<Map<String, dynamic>?> getDeletionStatus();
  Future<void> cancelDeletion();
}

@LazySingleton(as: AccountDeletionRemoteDataSource)
class AccountDeletionRemoteDataSourceImpl implements AccountDeletionRemoteDataSource {
  final Dio dio;
  AccountDeletionRemoteDataSourceImpl({@Named('dio') required this.dio});

  @override
  Future<Map<String, dynamic>> requestDeletion({String? reason}) async {
    try {
      final resp = await dio.post('/api/account/delete-request', data: {'reason': reason});
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return resp.data['data'] as Map<String, dynamic>;
      }
      throw ServerException(resp.data['message'] ?? 'Failed to request deletion');
    } on DioException catch (e) {
      final msg = e.response?.data is Map ? e.response?.data['message'] : null;
      throw ServerException(msg ?? e.message ?? 'Server error');
    }
  }

  @override
  Future<Map<String, dynamic>?> getDeletionStatus() async {
    try {
      final resp = await dio.get('/api/account/delete-request');
      if (resp.statusCode == 200) {
        final data = resp.data['data'] as Map<String, dynamic>?;
        if (data != null && data['has_request'] == true) {
          return data;
        }
        return null;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ServerException(
        (e.response?.data is Map ? e.response?.data['message'] : null) ?? e.message ?? 'Server error',
      );
    }
  }

  @override
  Future<void> cancelDeletion() async {
    try {
      await dio.post('/api/account/delete-request/cancel');
    } on DioException catch (e) {
      final msg = e.response?.data is Map ? e.response?.data['message'] : null;
      throw ServerException(msg ?? e.message ?? 'Server error');
    }
  }
}
