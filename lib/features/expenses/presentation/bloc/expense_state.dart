import 'package:equatable/equatable.dart';

import '../../domain/entities/expense.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();
}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;

  const ExpenseLoaded(this.expenses);

  @override
  List<Object?> get props => [expenses];
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object?> get props => [message];
}
