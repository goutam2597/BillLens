import 'package:equatable/equatable.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpensesRequested extends ExpenseEvent {
  const LoadExpensesRequested();
}

class SearchExpensesRequested extends ExpenseEvent {
  final String query;

  const SearchExpensesRequested(this.query);

  @override
  List<Object?> get props => [query];
}

class DeleteExpenseRequested extends ExpenseEvent {
  final String id;

  const DeleteExpenseRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class ExpenseCreated extends ExpenseEvent {
  const ExpenseCreated();
}

class ExpenseUpdated extends ExpenseEvent {
  const ExpenseUpdated();
}

class ExpenseDeletedExternally extends ExpenseEvent {
  final String id;

  const ExpenseDeletedExternally(this.id);

  @override
  List<Object?> get props => [id];
}
