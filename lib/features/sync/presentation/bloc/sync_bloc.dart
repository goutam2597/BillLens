import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../expenses/domain/repositories/expense_repository.dart';
import 'sync_event.dart';
import 'sync_state.dart';

@injectable
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final ExpenseRepository _expenseRepository;

  SyncBloc({required ExpenseRepository expenseRepository})
      : _expenseRepository = expenseRepository,
        super(const SyncInitial()) {
    on<LoadSyncStatus>(_onLoadSyncStatus);
    on<StartManualSync>(_onStartManualSync);
    on<RetryFailedSync>(_onRetryFailedSync);
    on<AutoSyncStarted>(_onAutoSyncStarted);
  }

  Future<void> _onLoadSyncStatus(
    LoadSyncStatus event,
    Emitter<SyncState> emit,
  ) async {
    final result = await _expenseRepository.getExpenses();
    result.fold(
      (failure) => emit(SyncFailed(failure.message)),
      (expenses) {
        final pending = expenses.where((e) => e.syncStatus == 'pending').length;
        final failed = expenses.where((e) => e.syncStatus == 'failed').length;
        emit(SyncIdle(
          offlineExpenses: expenses.length,
          pendingSync: pending,
          failedSync: failed,
        ));
      },
    );
  }

  Future<void> _onStartManualSync(
    StartManualSync event,
    Emitter<SyncState> emit,
  ) async {
    final currentState = state;
    var pendingCount = 0;
    if (currentState is SyncIdle) {
      pendingCount = currentState.pendingSync;
    }

    emit(SyncInProgress(
      totalItems: pendingCount,
      syncedItems: 0,
      currentItem: 'Starting sync...',
    ));

    final result = await _expenseRepository.syncPendingExpenses();
    
    result.fold(
      (failure) {
        emit(SyncFailed(failure.message));
        add(LoadSyncStatus());
      },
      (synced) async {
        emit(SyncCompleted(syncedCount: synced));
        await Future<void>.delayed(const Duration(seconds: 1));
        add(LoadSyncStatus());
      },
    );
  }

  Future<void> _onRetryFailedSync(
    RetryFailedSync event,
    Emitter<SyncState> emit,
  ) async {
    add(StartManualSync());
  }

  Future<void> _onAutoSyncStarted(
    AutoSyncStarted event,
    Emitter<SyncState> emit,
  ) async {
    add(StartManualSync());
  }
}
