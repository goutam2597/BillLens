import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_data_source.dart';
import '../datasources/expense_remote_data_source.dart';
import '../models/expense_model.dart';

@LazySingleton(as: ExpenseRepository)
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<Expense>>> getExpenses() async {
    try {
      final expenses = await localDataSource.getExpenses();
      return Right(expenses);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense?>> getExpenseById(String id) async {
    try {
      final expense = await localDataSource.getExpenseById(id);
      return Right(expense);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> searchExpenses(String query) async {
    try {
      final expenses = await localDataSource.searchExpenses(query);
      return Right(expenses);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense>> createExpense(Expense expense) async {
    try {
      var model = ExpenseModel.fromEntity(expense);
      model = await localDataSource.createExpense(model);
      try {
        final synced = await remoteDataSource.createExpense(model);
        await localDataSource.updateExpense(synced);
        return Right(synced);
      } catch (_) {
        return Right(model);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense>> updateExpense(Expense expense) async {
    try {
      var model = ExpenseModel.fromEntity(expense);
      model = await localDataSource.updateExpense(model);
      try {
        final synced = await remoteDataSource.updateExpense(model);
        await localDataSource.updateExpense(synced);
        return Right(synced);
      } catch (_) {
        return Right(model);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String id) async {
    try {
      await localDataSource.deleteExpense(id);
      try {
        await remoteDataSource.deleteExpense(id);
      } catch (_) {
        // Leave as pending sync.
      }
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
