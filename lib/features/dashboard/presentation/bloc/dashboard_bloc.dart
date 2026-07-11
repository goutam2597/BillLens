import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/connectivity_service.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../expenses/presentation/bloc/expense_change_notifier.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ExpenseRepository _expenseRepository;
  final ConnectivityService _connectivity;
  final ExpenseChangeNotifier _changeNotifier;
  late final StreamSubscription<ExpenseChangeEvent> _changesSubscription;

  DashboardBloc({
    required ExpenseRepository expenseRepository,
    required ConnectivityService connectivityService,
    required ExpenseChangeNotifier changeNotifier,
  })  : _expenseRepository = expenseRepository,
        _connectivity = connectivityService,
        _changeNotifier = changeNotifier,
        super(const DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<LoadRecentExpenses>(_onLoadRecentExpenses);
    on<CheckSyncStatus>(_onCheckSyncStatus);
    on<DashboardDataChanged>(_onDataChanged);
    _changesSubscription = _changeNotifier.stream.listen(
      (event) => add(const DashboardDataChanged()),
    );
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());

    final online = await _connectivity.isOnline;
    final result = await _expenseRepository.getExpenses();

    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (expenses) {
        final now = DateTime.now();
        final monthlyExpenses = expenses.where(
          (e) => e.date.year == now.year && e.date.month == now.month,
        );
        final monthlyTotal = monthlyExpenses.fold<double>(
          0.0,
          (sum, e) => sum + e.amount,
        );
        final recent = expenses.take(5).toList();
        emit(DashboardLoaded(
          monthlyTotal: monthlyTotal,
          expenseCount: expenses.length,
          recentExpenses: recent,
          pendingSyncCount:
              expenses.where((e) => e.syncStatus == 'pending').length,
          isOnline: online,
        ));
      },
    );
  }

  Future<void> _onLoadRecentExpenses(
    LoadRecentExpenses event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await _expenseRepository.getExpenses();
    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (expenses) {
        final recent = expenses.take(5).toList();
        if (state is DashboardLoaded) {
          final current = state as DashboardLoaded;
          emit(current.copyWith(recentExpenses: recent));
        } else {
          emit(DashboardLoaded(
            monthlyTotal: 0,
            expenseCount: expenses.length,
            recentExpenses: recent,
          ));
        }
      },
    );
  }

  Future<void> _onCheckSyncStatus(
    CheckSyncStatus event,
    Emitter<DashboardState> emit,
  ) async {
    final online = await _connectivity.isOnline;
    final result = await _expenseRepository.getExpenses();
    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (expenses) {
        final pending =
            expenses.where((e) => e.syncStatus == 'pending').length;
        if (state is DashboardLoaded) {
          final current = state as DashboardLoaded;
          emit(current.copyWith(pendingSyncCount: pending, isOnline: online));
        }
      },
    );
  }

  Future<void> _onDataChanged(
    DashboardDataChanged event,
    Emitter<DashboardState> emit,
  ) async {
    // Any expense change from another screen triggers a lightweight reload.
    final online = await _connectivity.isOnline;
    final result = await _expenseRepository.getExpenses();
    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (expenses) {
        final now = DateTime.now();
        final monthlyExpenses = expenses.where(
          (e) => e.date.year == now.year && e.date.month == now.month,
        );
        final monthlyTotal = monthlyExpenses.fold<double>(
          0.0,
          (sum, e) => sum + e.amount,
        );
        final recent = expenses.take(5).toList();
        emit(DashboardLoaded(
          monthlyTotal: monthlyTotal,
          expenseCount: expenses.length,
          recentExpenses: recent,
          pendingSyncCount:
              expenses.where((e) => e.syncStatus == 'pending').length,
          isOnline: online,
        ));
      },
    );
  }

  @override
  Future<void> close() async {
    await _changesSubscription.cancel();
    return super.close();
  }
}
