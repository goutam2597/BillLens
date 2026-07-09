import 'package:equatable/equatable.dart';

import '../../domain/entities/expense.dart';

abstract class ExpenseDetailsState extends Equatable {
  const ExpenseDetailsState();

  @override
  List<Object?> get props => [];
}

class ExpenseDetailsInitial extends ExpenseDetailsState {
  const ExpenseDetailsInitial();
}

class ExpenseDetailsLoading extends ExpenseDetailsState {
  const ExpenseDetailsLoading();
}

class ExpenseDetailsLoaded extends ExpenseDetailsState {
  final Expense expense;

  const ExpenseDetailsLoaded(this.expense);

  @override
  List<Object?> get props => [expense];
}

class ExpenseDetailsDeleted extends ExpenseDetailsState {
  const ExpenseDetailsDeleted();
}

class ExpenseDetailsError extends ExpenseDetailsState {
  final String message;

  const ExpenseDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
