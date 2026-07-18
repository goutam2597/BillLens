import 'package:equatable/equatable.dart';

import '../../domain/entities/expense.dart';
import 'package:billlens/core/local/currency_service.dart';

class ExpenseFormState extends Equatable {
  final Expense expense;
  final bool isSubmitting;
  final bool isValid;
  final String? errorMessage;
  final bool isSuccess;
  // ── FIXED LIMITS ──
  final bool isLimitExceeded;
  final String? limitCode; // SCAN_LIMIT_EXCEEDED / MANUAL_LIMIT_EXCEEDED
  final Map<String, dynamic>? limitUsage;
  // ── DUPLICATE HANDLING ──
  final bool isDuplicate;
  final Map<String, dynamic>? duplicateExpense;

  const ExpenseFormState({
    required this.expense,
    this.isSubmitting = false,
    this.isValid = false,
    this.errorMessage,
    this.isSuccess = false,
    this.isLimitExceeded = false,
    this.limitCode,
    this.limitUsage,
    this.isDuplicate = false,
    this.duplicateExpense,
  });

  ExpenseFormState copyWith({
    Expense? expense,
    bool? isSubmitting,
    bool? isValid,
    String? errorMessage,
    bool? isSuccess,
    bool? isLimitExceeded,
    String? limitCode,
    Map<String, dynamic>? limitUsage,
    bool? isDuplicate,
    Map<String, dynamic>? duplicateExpense,
  }) {
    return ExpenseFormState(
      expense: expense ?? this.expense,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      isLimitExceeded: isLimitExceeded ?? this.isLimitExceeded,
      limitCode: limitCode ?? this.limitCode,
      limitUsage: limitUsage ?? this.limitUsage,
      isDuplicate: isDuplicate ?? this.isDuplicate,
      duplicateExpense: duplicateExpense ?? this.duplicateExpense,
    );
  }

  @override
  List<Object?> get props => [
        expense,
        isSubmitting,
        isValid,
        errorMessage,
        isSuccess,
        isLimitExceeded,
        limitCode,
        limitUsage,
        isDuplicate,
        duplicateExpense,
      ];
}

Expense _emptyExpense() {
  final now = DateTime.now();
  final currency = CurrencyService.resolveSync();
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
