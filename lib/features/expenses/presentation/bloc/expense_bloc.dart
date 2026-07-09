import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/usecase.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import '../../domain/usecases/search_expenses_usecase.dart';
import 'expense_event.dart';
import 'expense_state.dart';

export 'expense_event.dart';
export 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetExpensesUseCase _getExpensesUseCase;
  final SearchExpensesUseCase _searchExpensesUseCase;
  final DeleteExpenseUseCase _deleteExpenseUseCase;

  ExpenseBloc({
    required GetExpensesUseCase getExpensesUseCase,
    required SearchExpensesUseCase searchExpensesUseCase,
    required DeleteExpenseUseCase deleteExpenseUseCase,
  })  : _getExpensesUseCase = getExpensesUseCase,
        _searchExpensesUseCase = searchExpensesUseCase,
        _deleteExpenseUseCase = deleteExpenseUseCase,
        super(const ExpenseInitial()) {
    on<LoadExpensesRequested>(_onLoad);
    on<SearchExpensesRequested>(_onSearch);
    on<DeleteExpenseRequested>(_onDelete);
  }

  Future<void> _onLoad(
    LoadExpensesRequested event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(const ExpenseLoading());
    final result = await _getExpensesUseCase(const NoParams());
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (expenses) => emit(ExpenseLoaded(expenses)),
    );
  }

  Future<void> _onSearch(
    SearchExpensesRequested event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(const ExpenseLoading());
    final result =
        await _searchExpensesUseCase(SearchExpensesParams(event.query));
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (expenses) => emit(ExpenseLoaded(expenses)),
    );
  }

  Future<void> _onDelete(
    DeleteExpenseRequested event,
    Emitter<ExpenseState> emit,
  ) async {
    final currentState = state;
    if (currentState is ExpenseLoaded) {
      // Optimistically remove from the list.
      emit(ExpenseLoaded(
        currentState.expenses.where((e) => e.id != event.id).toList(),
      ));
    }
    final result = await _deleteExpenseUseCase(DeleteExpenseParams(event.id));
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (_) => add(const LoadExpensesRequested()),
    );
  }
}
