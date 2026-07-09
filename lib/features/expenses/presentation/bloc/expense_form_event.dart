import 'package:equatable/equatable.dart';

import '../../domain/entities/expense.dart';

abstract class ExpenseFormEvent extends Equatable {
  const ExpenseFormEvent();

  @override
  List<Object?> get props => [];
}

class InitializeExpenseForm extends ExpenseFormEvent {
  final Expense? expense;

  const InitializeExpenseForm({this.expense});

  @override
  List<Object?> get props => [expense];
}

class ExpenseDraftUpdated extends ExpenseFormEvent {
  final Expense expense;

  const ExpenseDraftUpdated(this.expense);

  @override
  List<Object?> get props => [expense];
}

class SubmitExpenseForm extends ExpenseFormEvent {
  const SubmitExpenseForm();
}
