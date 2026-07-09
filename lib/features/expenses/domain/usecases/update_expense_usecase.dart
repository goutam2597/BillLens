import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

@lazySingleton
class UpdateExpenseUseCase implements UseCase<Expense, Expense> {
  final ExpenseRepository repository;

  UpdateExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, Expense>> call(Expense params) async {
    return repository.updateExpense(params);
  }
}
