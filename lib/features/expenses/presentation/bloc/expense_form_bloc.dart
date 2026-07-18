import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/create_expense_usecase.dart';
import '../../domain/usecases/update_expense_usecase.dart';
import 'expense_form_event.dart';
import 'expense_form_state.dart';

export 'expense_form_event.dart';
export 'expense_form_state.dart';

class ExpenseFormBloc extends Bloc<ExpenseFormEvent, ExpenseFormState> {
  final CreateExpenseUseCase _createExpenseUseCase;
  final UpdateExpenseUseCase _updateExpenseUseCase;

  ExpenseFormBloc({
    required CreateExpenseUseCase createExpenseUseCase,
    required UpdateExpenseUseCase updateExpenseUseCase,
  })  : _createExpenseUseCase = createExpenseUseCase,
        _updateExpenseUseCase = updateExpenseUseCase,
        super(ExpenseFormInitial()) {
    on<InitializeExpenseForm>(_onInitialize);
    on<ExpenseDraftUpdated>(_onDraftUpdated);
    on<SubmitExpenseForm>(_onSubmit);
  }

  void _onInitialize(
    InitializeExpenseForm event,
    Emitter<ExpenseFormState> emit,
  ) {
    emit(ExpenseFormState(
      expense: event.expense ?? state.expense,
      isValid: _validate(event.expense ?? state.expense),
    ));
  }

  void _onDraftUpdated(
    ExpenseDraftUpdated event,
    Emitter<ExpenseFormState> emit,
  ) {
    emit(state.copyWith(
      expense: event.expense,
      isValid: _validate(event.expense),
    ));
  }

  Future<void> _onSubmit(
    SubmitExpenseForm event,
    Emitter<ExpenseFormState> emit,
  ) async {
    if (!state.isValid) return;

    emit(state.copyWith(isSubmitting: true, errorMessage: null, isLimitExceeded: false, isDuplicate: false));

    final expense = state.expense;
    final result = expense.id.isEmpty
        ? await _createExpenseUseCase(expense)
        : await _updateExpenseUseCase(expense);

    result.fold(
      (failure) {
        if (failure is LimitExceededFailure) {
          emit(state.copyWith(
            isSubmitting: false,
            errorMessage: failure.message,
            isLimitExceeded: true,
            limitCode: failure.code,
            limitUsage: failure.usage,
          ));
        } else if (failure is DuplicateFailure) {
          emit(state.copyWith(
            isSubmitting: false,
            errorMessage: failure.message,
            isDuplicate: true,
            duplicateExpense: failure.existingExpense,
          ));
        } else {
          emit(state.copyWith(
            isSubmitting: false,
            errorMessage: failure.message,
          ));
        }
      },
      (_) => emit(state.copyWith(
        isSubmitting: false,
        isSuccess: true,
      )),
    );
  }

  bool _validate(Expense expense) {
    return expense.vendor.trim().isNotEmpty && expense.amount > 0;
  }
}
