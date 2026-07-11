import 'package:equatable/equatable.dart';

import '../../domain/entities/expense.dart';
import 'package:billlens/core/di/injection.dart';
import 'package:billlens/core/local/local_storage_service.dart';

class ExpenseFormState extends Equatable {
  final Expense expense;
  final bool isSubmitting;
  final bool isValid;
  final String? errorMessage;
  final bool isSuccess;

  const ExpenseFormState({
    required this.expense,
    this.isSubmitting = false,
    this.isValid = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ExpenseFormState copyWith({
    Expense? expense,
    bool? isSubmitting,
    bool? isValid,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ExpenseFormState(
      expense: expense ?? this.expense,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
        expense,
        isSubmitting,
        isValid,
        errorMessage,
        isSuccess,
      ];
}

Expense _emptyExpense() {
  final now = DateTime.now();
  String currency = 'USD';
  try {
    if (getIt.isRegistered<LocalStorageService>()) {
      currency = getIt<LocalStorageService>().currency;
    }
  } catch (_) {}
  return Expense(
    id: '',
    userId: '',
    vendor: '',
    amount: 0.0,
    currency: currency,
    date: now,
    syncStatus: 'pending',
    createdAt: now,
    updatedAt: now,
  );
}

class ExpenseFormInitial extends ExpenseFormState {
  ExpenseFormInitial() : super(expense: _emptyExpense());
}
