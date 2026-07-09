import 'package:equatable/equatable.dart';

abstract class ExpenseDetailsEvent extends Equatable {
  const ExpenseDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenseDetailsRequested extends ExpenseDetailsEvent {
  final String id;

  const LoadExpenseDetailsRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteExpenseDetailsRequested extends ExpenseDetailsEvent {
  final String id;

  const DeleteExpenseDetailsRequested(this.id);

  @override
  List<Object?> get props => [id];
}
