import 'package:equatable/equatable.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();
  @override
  List<Object?> get props => [];
}

class LoadSyncStatus extends SyncEvent {}

class StartManualSync extends SyncEvent {}

class RetryFailedSync extends SyncEvent {}

class AutoSyncStarted extends SyncEvent {}
