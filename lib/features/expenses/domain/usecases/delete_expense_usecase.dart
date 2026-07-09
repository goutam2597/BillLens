import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/expense_repository.dart';

class DeleteExpenseParams extends Equatable {
  final String id;

  const DeleteExpenseParams(this.id);

  @override
  List<Object> get props => [id];
}

@lazySingleton
class DeleteExpenseUseCase implements UseCase<void, DeleteExpenseParams> {
  final ExpenseRepository repository;

  DeleteExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteExpenseParams params) async {
    return repository.deleteExpense(params.id);
  }
}
