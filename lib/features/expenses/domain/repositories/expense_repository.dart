import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, List<Expense>>> getExpenses();
  Future<Either<Failure, Expense?>> getExpenseById(String id);
  Future<Either<Failure, List<Expense>>> searchExpenses(String query);
  Future<Either<Failure, Expense>> createExpense(Expense expense);
  Future<Either<Failure, Expense>> updateExpense(Expense expense);
  Future<Either<Failure, void>> deleteExpense(String id);
  Future<Either<Failure, int>> syncPendingExpenses();
}
