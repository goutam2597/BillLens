import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/expense_model.dart';

abstract class ExpenseRemoteDataSource {
  Future<List<ExpenseModel>> getExpenses(String userId);
  Future<ExpenseModel> getExpenseById(String id);
  Future<ExpenseModel> createExpense(ExpenseModel expense);
  Future<ExpenseModel> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
}

@LazySingleton(as: ExpenseRemoteDataSource)
class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final Dio dio;

  ExpenseRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ExpenseModel>> getExpenses(String userId) async {
    try {
      // Backend not implemented yet.
      await Future.delayed(const Duration(milliseconds: 800));
      return [];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ExpenseModel> getExpenseById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      throw ServerException('Expense not found on server');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ExpenseModel> createExpense(ExpenseModel expense) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      // Simulate a server-assigned ID.
      return expense.copyWithModel(
        serverId: 'srv_${expense.id}',
        syncStatus: 'synced',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      return expense.copyWithModel(syncStatus: 'synced');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
