import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

@lazySingleton
class GetExpensesUseCase implements UseCase<List<Expense>, NoParams> {
  final ExpenseRepository repository;

  GetExpensesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(NoParams params) async {
    return repository.getExpenses();
  }
}
