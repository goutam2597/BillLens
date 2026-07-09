import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class SearchExpensesParams extends Equatable {
  final String query;

  const SearchExpensesParams(this.query);

  @override
  List<Object> get props => [query];
}

@lazySingleton
class SearchExpensesUseCase
    implements UseCase<List<Expense>, SearchExpensesParams> {
  final ExpenseRepository repository;

  SearchExpensesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(SearchExpensesParams params) async {
    return repository.searchExpenses(params.query);
  }
}
