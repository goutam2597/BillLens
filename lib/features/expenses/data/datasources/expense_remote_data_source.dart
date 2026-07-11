import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/expense_model.dart';

abstract class ExpenseRemoteDataSource {
  Future<List<ExpenseModel>> getExpenses({int page = 1, int limit = 50});
  Future<ExpenseModel?> getExpenseById(int id);
  Future<ExpenseModel> createExpense(ExpenseModel expense);
  Future<ExpenseModel> updateExpense(int id, ExpenseModel expense);
  Future<void> deleteExpense(int id);
}

@LazySingleton(as: ExpenseRemoteDataSource)
class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final Dio dio;

  ExpenseRemoteDataSourceImpl({@Named('dio') required this.dio});

  @override
  Future<List<ExpenseModel>> getExpenses({int page = 1, int limit = 50}) async {
    try {
      final response = await dio.get('/api/expenses', queryParameters: {
        'page': page,
        'limit': limit,
      });
      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>? ?? [];
        return list.map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw ServerException(response.data['message'] ?? 'Failed to load expenses');
    } on DioException catch (e) {
      throw ServerException(
        (e.response?.data is Map ? e.response?.data['message'] : null) ?? e.message ?? 'Server error',
      );
    }
  }

  @override
  Future<ExpenseModel?> getExpenseById(int id) async {
    try {
      final response = await dio.get('/api/expenses/$id');
      if (response.statusCode == 200) {
        final json = response.data['data'] as Map<String, dynamic>;
        return ExpenseModel.fromJson(json);
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
  Future<ExpenseModel> createExpense(ExpenseModel expense) async {
    try {
      final response = await dio.post('/api/expenses', data: expense.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = response.data['data'] as Map<String, dynamic>;
        return ExpenseModel.fromJson(json).copyWithModel(syncStatus: 'synced');
      }
      throw ServerException(response.data['message'] ?? 'Failed to create expense');
    } on DioException catch (e) {
      throw ServerException(
        (e.response?.data is Map ? e.response?.data['message'] : null) ?? e.message ?? 'Server error',
      );
    }
  }

  @override
  Future<ExpenseModel> updateExpense(int id, ExpenseModel expense) async {
    try {
      final response = await dio.put('/api/expenses/$id', data: expense.toJson());
      if (response.statusCode == 200) {
        final json = response.data['data'] as Map<String, dynamic>;
        return ExpenseModel.fromJson(json).copyWithModel(syncStatus: 'synced');
      }
      throw ServerException(response.data['message'] ?? 'Failed to update expense');
    } on DioException catch (e) {
      throw ServerException(
        (e.response?.data is Map ? e.response?.data['message'] : null) ?? e.message ?? 'Server error',
      );
    }
  }

  @override
  Future<void> deleteExpense(int id) async {
    try {
      await dio.delete('/api/expenses/$id');
    } on DioException catch (e) {
      throw ServerException(
        (e.response?.data is Map ? e.response?.data['message'] : null) ?? e.message ?? 'Server error',
      );
    }
  }
}
