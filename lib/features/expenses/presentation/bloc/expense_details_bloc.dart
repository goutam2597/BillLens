import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/delete_expense_usecase.dart';
import '../../domain/usecases/get_expense_by_id_usecase.dart';
import 'expense_details_event.dart';
import 'expense_details_state.dart';

export 'expense_details_event.dart';
export 'expense_details_state.dart';

class ExpenseDetailsBloc
    extends Bloc<ExpenseDetailsEvent, ExpenseDetailsState> {
  final GetExpenseByIdUseCase _getExpenseByIdUseCase;
  final DeleteExpenseUseCase _deleteExpenseUseCase;

  ExpenseDetailsBloc({
    required GetExpenseByIdUseCase getExpenseByIdUseCase,
    required DeleteExpenseUseCase deleteExpenseUseCase,
  })  : _getExpenseByIdUseCase = getExpenseByIdUseCase,
        _deleteExpenseUseCase = deleteExpenseUseCase,
        super(const ExpenseDetailsInitial()) {
    on<LoadExpenseDetailsRequested>(_onLoad);
    on<DeleteExpenseDetailsRequested>(_onDelete);
  }

  Future<void> _onLoad(
    LoadExpenseDetailsRequested event,
    Emitter<ExpenseDetailsState> emit,
  ) async {
    emit(const ExpenseDetailsLoading());
    final result =
        await _getExpenseByIdUseCase(GetExpenseByIdParams(event.id));
    result.fold(
      (failure) => emit(ExpenseDetailsError(failure.message)),
      (expense) {
        if (expense == null) {
          emit(const ExpenseDetailsError('Expense not found'));
        } else {
          emit(ExpenseDetailsLoaded(expense));
        }
      },
    );
  }

  Future<void> _onDelete(
    DeleteExpenseDetailsRequested event,
    Emitter<ExpenseDetailsState> emit,
  ) async {
    emit(const ExpenseDetailsLoading());
    final result =
        await _deleteExpenseUseCase(DeleteExpenseParams(event.id));
    result.fold(
      (failure) => emit(ExpenseDetailsError(failure.message)),
      (_) => emit(const ExpenseDetailsDeleted()),
    );
  }
}
