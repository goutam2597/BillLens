import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_data_source.dart';
import '../datasources/expense_remote_data_source.dart';
import '../models/expense_model.dart';

@LazySingleton(as: ExpenseRepository)
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;
  final ExpenseRemoteDataSource remoteDataSource;
  final ConnectivityService _connectivity;

  ExpenseRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required ConnectivityService connectivityService,
  }) : _connectivity = connectivityService;

  @override
  Future<Either<Failure, List<Expense>>> getExpenses() async {
    try {
      final online = await _connectivity.isOnline;

      if (online) {
        try {
          // Fetch from remote
          final remoteExpenses = await remoteDataSource.getExpenses();

          // Fetch current local expenses
          final localExpenses = await localDataSource.getExpenses();
          
          // Clean up corrupted duplicates
          final seenLocalIdsToWipe = <String>{};
          for (final local in localExpenses) {
            if (local.serverId != null) {
              if (!seenLocalIdsToWipe.contains(local.id)) {
                await localDataSource.hardDeleteExpense(local.id);
                seenLocalIdsToWipe.add(local.id);
              }
            } else if (local.syncStatus == 'synced') {
              // Corrupted local item marked as synced but no server ID
              await localDataSource.hardDeleteExpense(local.id);
              seenLocalIdsToWipe.add(local.id);
            }
          }

          // Reload local expenses after wipe to get remaining pending offline items
          var remainingLocals = await localDataSource.getExpenses();

          // Insert fresh remote data
          for (final model in remoteExpenses) {
            if (model.serverId == null) continue;

            // Check if there is an offline item that perfectly matches this remote item
            final matchingOffline = remainingLocals
                .where((e) =>
                    e.serverId == null &&
                    e.vendor.trim().toLowerCase() ==
                        model.vendor.trim().toLowerCase() &&
                    e.amount == model.amount &&
                    e.date.year == model.date.year &&
                    e.date.month == model.date.month &&
                    e.date.day == model.date.day)
                .toList();

            if (matchingOffline.isNotEmpty) {
              // Update the offline item with the server data to link them
              final target = matchingOffline.first;
              await localDataSource
                  .updateExpense(model.copyWithModel(id: target.id));
              // Remove from memory so we don't match it twice
              remainingLocals.remove(target);
            } else {
              // Create fresh
              await localDataSource.createExpense(model);
            }
          }

          final cached = await localDataSource.getExpenses();
          return Right(cached);
        } catch (_) {
          // Remote failed — fallback to local
          final local = await localDataSource.getExpenses();
          return Right(local);
        }
      } else {
        // Offline — serve from local DB
        final local = await localDataSource.getExpenses();
        return Right(local);
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense?>> getExpenseById(String id) async {
    try {
      final online = await _connectivity.isOnline;
      final expense = await localDataSource.getExpenseById(id);
      if (expense != null && online && expense.serverId != null) {
        try {
          final serverId = int.tryParse(expense.serverId!);
          if (serverId != null) {
            final remote = await remoteDataSource.getExpenseById(serverId);
            if (remote != null) {
              await localDataSource.updateExpense(remote);
              return Right(remote);
            }
          }
        } catch (_) {}
      }
      return Right(expense);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> searchExpenses(String query) async {
    try {
      final expenses = await localDataSource.searchExpenses(query);
      return Right(expenses);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense>> createExpense(Expense expense) async {
    try {
      var model = ExpenseModel.fromEntity(expense);
      model = await localDataSource.createExpense(model);

      final online = await _connectivity.isOnline;
      if (online) {
        try {
          final synced = await remoteDataSource.createExpense(model);
          await localDataSource.updateExpense(synced);
          return Right(synced);
        } catch (_) {
          // Will sync later
        }
      }
      return Right(model);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense>> updateExpense(Expense expense) async {
    try {
      var model = ExpenseModel.fromEntity(expense);
      model = await localDataSource.updateExpense(model);

      final online = await _connectivity.isOnline;
      if (online) {
        try {
          final serverId = int.tryParse(model.serverId ?? '');
          if (serverId != null) {
            final synced =
                await remoteDataSource.updateExpense(serverId, model);
            await localDataSource.updateExpense(synced);
            return Right(synced);
          }
        } catch (_) {
          // Will sync later
        }
      }
      return Right(model);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String id) async {
    try {
      await localDataSource.deleteExpense(id);

      final online = await _connectivity.isOnline;
      if (online) {
        try {
          final expense = await localDataSource.getExpenseById(id);
          if (expense?.serverId != null) {
            final serverId = int.tryParse(expense!.serverId!);
            if (serverId != null) {
              await remoteDataSource.deleteExpense(serverId);
            }
          }
        } catch (_) {}
      }
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> syncPendingExpenses() async {
    try {
      final online = await _connectivity.isOnline;
      if (!online) return const Right(0);

      final localExpenses = await localDataSource.getExpenses();
      final pending =
          localExpenses.where((e) => e.syncStatus == 'pending').toList();

      int syncedCount = 0;
      for (final expense in pending) {
        try {
          if (expense.isDeleted) {
            if (expense.serverId != null) {
              final sId = int.tryParse(expense.serverId!);
              if (sId != null) await remoteDataSource.deleteExpense(sId);
            }
          } else if (expense.serverId != null) {
            final sId = int.tryParse(expense.serverId!);
            if (sId != null) {
              final synced = await remoteDataSource.updateExpense(sId, expense);
              await localDataSource.updateExpense(synced);
            }
          } else {
            final synced = await remoteDataSource.createExpense(expense);
            await localDataSource.updateExpense(synced);
          }
          syncedCount++;
        } catch (_) {
          // Failed to sync this particular item, skip it
        }
      }
      return Right(syncedCount);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
