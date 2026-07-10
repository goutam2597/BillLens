import 'package:equatable/equatable.dart';

abstract class SyncState extends Equatable {
  const SyncState();
  @override
  List<Object?> get props => [];
}

class SyncInitial extends SyncState {
  const SyncInitial();
}

class SyncIdle extends SyncState {
  final int offlineExpenses;
  final int pendingSync;
  final int failedSync;
  final DateTime? lastSyncTime;

  const SyncIdle({
    this.offlineExpenses = 0,
    this.pendingSync = 0,
    this.failedSync = 0,
    this.lastSyncTime,
  });

  @override
  List<Object?> get props => [offlineExpenses, pendingSync, failedSync, lastSyncTime];
}

class SyncInProgress extends SyncState {
  final int totalItems;
  final int syncedItems;
  final String currentItem;

  const SyncInProgress({
    this.totalItems = 0,
    this.syncedItems = 0,
    this.currentItem = '',
  });

  double get progress => totalItems > 0 ? syncedItems / totalItems : 0;

  @override
  List<Object> get props => [totalItems, syncedItems, currentItem];
}

class SyncCompleted extends SyncState {
  final int syncedCount;
  final int failedCount;
  final DateTime syncTime;

  SyncCompleted({
    required this.syncedCount,
    this.failedCount = 0,
    DateTime? syncTime,
  }) : syncTime = syncTime ?? DateTime.now();

  @override
  List<Object> get props => [syncedCount, failedCount, syncTime];
}

class SyncFailed extends SyncState {
  final String message;
  const SyncFailed(this.message);
  @override
  List<Object> get props => [message];
}
