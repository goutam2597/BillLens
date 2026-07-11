import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/usecase.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import '../../domain/usecases/search_expenses_usecase.dart';
import 'expense_change_notifier.dart';
import 'expense_event.dart';
import 'expense_state.dart';

export 'expense_event.dart';
export 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetExpensesUseCase _getExpensesUseCase;
  final SearchExpensesUseCase _searchExpensesUseCase;
  final DeleteExpenseUseCase _deleteExpenseUseCase;
  final ExpenseChangeNotifier _changeNotifier;

  ExpenseBloc({
    required GetExpensesUseCase getExpensesUseCase,
    required SearchExpensesUseCase searchExpensesUseCase,
    required DeleteExpenseUseCase deleteExpenseUseCase,
    required ExpenseChangeNotifier changeNotifier,
  })  : _getExpensesUseCase = getExpensesUseCase,
        _searchExpensesUseCase = searchExpensesUseCase,
        _deleteExpenseUseCase = deleteExpenseUseCase,
        _changeNotifier = changeNotifier,
        super(const ExpenseInitial()) {
    on<LoadExpensesRequested>(_onLoad);
    on<SearchExpensesRequested>(_onSearch);
    on<DeleteExpenseRequested>(_onDelete);
    on<ExpenseCreated>(_onExpenseChanged);
    on<ExpenseUpdated>(_onExpenseChanged);
    on<ExpenseDeletedExternally>(_onExpenseDeletedExternally);
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
    final previous = currentState is ExpenseLoaded ? currentState.expenses : null;

    if (previous != null) {
      // Optimistically remove from the list.
      emit(ExpenseLoaded(
        previous.where((e) => e.id != event.id).toList(),
      ));
    }

    final result = await _deleteExpenseUseCase(DeleteExpenseParams(event.id));
    await result.fold(
      (failure) async => emit(ExpenseError(failure.message)),
      (_) async {
        // Notify other screens instead of reloading the whole list.
        _changeNotifier.notify(ExpenseChangeType.deleted, id: event.id);
      },
    );
  }

  void _onExpenseChanged(
    ExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) {
    // A new or updated expense was added from another screen.
    // Keep the current cached list; the user can pull-to-refresh for fresh data.
    // This avoids mid-scroll jumps caused by remote reloads.
  }

  void _onExpenseDeletedExternally(
    ExpenseDeletedExternally event,
    Emitter<ExpenseState> emit,
  ) {
    final currentState = state;
    if (currentState is ExpenseLoaded) {
      final updated =
          currentState.expenses.where((e) => e.id != event.id).toList();
      if (updated.length != currentState.expenses.length) {
        emit(ExpenseLoaded(updated));
      }
    }
  }

  @override
  Future<void> close() {
    _changeNotifier.dispose();
    return super.close();
  }
}
