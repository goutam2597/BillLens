import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class GetExpenseByIdParams extends Equatable {
  final String id;

  const GetExpenseByIdParams(this.id);

  @override
  List<Object> get props => [id];
}

@lazySingleton
class GetExpenseByIdUseCase implements UseCase<Expense?, GetExpenseByIdParams> {
  final ExpenseRepository repository;

  GetExpenseByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Expense?>> call(GetExpenseByIdParams params) async {
    return repository.getExpenseById(params.id);
  }
}
