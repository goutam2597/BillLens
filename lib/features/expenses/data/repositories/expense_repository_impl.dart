import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
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
  final AuthLocalDataSource _authLocal;

  ExpenseRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required ConnectivityService connectivityService,
    required AuthLocalDataSource authLocalDataSource,
  })  : _connectivity = connectivityService,
        _authLocal = authLocalDataSource;

  Future<bool> _isPremiumUser() async {
    try {
      final cached = await _authLocal.getCachedUser();
      if (cached != null) {
        return cached.subscriptionStatus == AppConstants.planPremium;
      }
    } catch (_) {}
    return false;
  }

  bool _isManualModel(ExpenseModel model) {
    final local = model.receiptImageLocalPath;
    final remote = model.receiptImageRemoteUrl;
    return (local == null || local.isEmpty) && (remote == null || remote.isEmpty);
  }

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

          final remainingRemote = List<ExpenseModel>.from(remoteExpenses);
          final pendingLocals =
              localExpenses.where((l) => l.serverId == null).toList();

          for (final local in localExpenses) {
            if (local.serverId != null) {
              final remoteIndex = remainingRemote
                  .indexWhere((r) => r.serverId == local.serverId);
              if (remoteIndex >= 0) {
                final remote = remainingRemote.removeAt(remoteIndex);
                await localDataSource
                    .updateExpense(remote.copyWithModel(id: local.id));
              } else {
                // Deleted on server or no longer accessible
                await localDataSource.hardDeleteExpense(local.id);
              }
            } else if (local.syncStatus == 'synced') {
              // Corrupted local item marked as synced but no server ID
              await localDataSource.hardDeleteExpense(local.id);
            }
          }

          for (final remote in remainingRemote) {
            if (remote.serverId == null) continue;

            final matchIndex = pendingLocals.indexWhere((l) =>
                l.vendor.trim().toLowerCase() ==
                    remote.vendor.trim().toLowerCase() &&
                l.amount == remote.amount &&
                l.date.year == remote.date.year &&
                l.date.month == remote.date.month &&
                l.date.day == remote.date.day);

            if (matchIndex >= 0) {
              final local = pendingLocals.removeAt(matchIndex);
              await localDataSource
                  .updateExpense(remote.copyWithModel(id: local.id));
            } else {
              await localDataSource.createExpense(remote);
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

      // ── FIXED LIMITS: Local pre-check for manual expenses (offline + UX) ──
      if (_isManualModel(model)) {
        final isPremium = await _isPremiumUser();
        if (!isPremium) {
          final monthlyManual = await localDataSource.getMonthlyManualCount();
          if (monthlyManual >= AppConstants.freeManualExpensesLimit) {
            return Left(LimitExceededFailure(
              'Monthly manual expense limit reached (${AppConstants.freeManualExpensesLimit}/month for free). Upgrade to premium for unlimited expenses.',
              code: 'MANUAL_LIMIT_EXCEEDED',
              usage: {
                'used': monthlyManual,
                'limit': AppConstants.freeManualExpensesLimit,
                'remaining': 0,
              },
            ));
          }
        }
      }

      final duplicate = await localDataSource.findDuplicateExpense(model);
      if (duplicate != null) {
        return const Left(DuplicateFailure(
            'An expense with this receipt number, vendor, date, and amount already exists.'));
      }

      model = await localDataSource.createExpense(model);

      final online = await _connectivity.isOnline;
      if (online) {
        try {
          final synced = await remoteDataSource.createExpense(model);
          await localDataSource.updateExpense(synced);
          return Right(synced);
        } on LimitExceededException catch (e) {
          // Backend limit reached — keep local as pending? Actually we should revert local creation
          // For manual limit, we already counted locally, but backend says over limit
          // Delete local pending to avoid sync loop, return failure
          await localDataSource.hardDeleteExpense(model.id);
          return Left(LimitExceededFailure(e.message, code: e.code, usage: e.usage));
        } on DuplicateException catch (e) {
          await localDataSource.hardDeleteExpense(model.id);
          return Left(DuplicateFailure(e.message, existingExpense: e.existingExpense));
        } on ServerException catch (e) {
          if (e.message.toLowerCase().contains('duplicate') || e.message.toLowerCase().contains('already exists')) {
            await localDataSource.hardDeleteExpense(model.id);
            return Left(DuplicateFailure(e.message));
          }
          // Will sync later
        } catch (_) {
          // Will sync later
        }
      }
      return Right(model);
    } on LimitExceededFailure catch (e) {
      return Left(e);
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

      // Check if transitioning to manual (e.g., removing receipt) would exceed limit
      final existing = await localDataSource.getExpenseById(model.id);
      if (existing != null) {
        final wasManual = _isManualModel(existing);
        final nowManual = _isManualModel(model);
        if (!wasManual && nowManual) {
          final isPremium = await _isPremiumUser();
          if (!isPremium) {
            final monthlyManual = await localDataSource.getMonthlyManualCount();
            if (monthlyManual >= AppConstants.freeManualExpensesLimit) {
              return Left(LimitExceededFailure(
                'Monthly manual expense limit reached. Removing receipt would exceed manual limit for free users.',
                code: 'MANUAL_LIMIT_EXCEEDED',
                usage: {
                  'used': monthlyManual,
                  'limit': AppConstants.freeManualExpensesLimit,
                },
              ));
            }
          }
        }
      }

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
        } on LimitExceededException catch (e) {
          return Left(LimitExceededFailure(e.message, code: e.code, usage: e.usage));
        } catch (_) {
          // Will sync later
        }
      }
      return Right(model);
    } on LimitExceededFailure catch (e) {
      return Left(e);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String id) async {
    try {
      // Get the expense first so we have the serverId
      final expense = await localDataSource.getExpenseById(id);

      // Delete locally
      await localDataSource.deleteExpense(id);

      final online = await _connectivity.isOnline;
      if (online && expense != null && expense.serverId != null) {
        try {
          final serverId = int.tryParse(expense.serverId!);
          if (serverId != null) {
            await remoteDataSource.deleteExpense(serverId);
            // Successfully deleted from global db, now hard delete from local db to keep it clean
            await localDataSource.hardDeleteExpense(id);
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

      final pending = await localDataSource.getPendingExpenses();

      int syncedCount = 0;
      for (final expense in pending) {
        try {
          if (expense.isDeleted) {
            if (expense.serverId != null) {
              final sId = int.tryParse(expense.serverId!);
              if (sId != null) {
                await remoteDataSource.deleteExpense(sId);
                await localDataSource.hardDeleteExpense(expense.id);
              }
            } else {
              // Local-only pending delete; just remove it
              await localDataSource.hardDeleteExpense(expense.id);
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
        } on LimitExceededException catch (_) {
          // Leave in pending queue — will fail again until next month or upgrade
          // Do not increment syncedCount, but also do not delete — user should see failure via sync status
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
