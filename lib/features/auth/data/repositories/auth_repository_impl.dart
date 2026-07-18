import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/local/local_storage_service.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<void> _syncCurrencyToPrefs(String currency) async {
    try {
      if (getIt.isRegistered<LocalStorageService>()) {
        await getIt<LocalStorageService>().syncCurrencyFromServer(currency);
      }
    } catch (_) {}
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      if (userModel.token != null) {
        await localDataSource.cacheToken(userModel.token!);
      }
      await localDataSource.cacheUser(userModel);
      await _syncCurrencyToPrefs(userModel.currency);
      return Right(userModel);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    String? businessName,
    required String currency,
  }) async {
    try {
      final userModel = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        businessName: businessName,
        currency: currency,
      );
      if (userModel.token != null) {
        await localDataSource.cacheToken(userModel.token!);
      }
      await localDataSource.cacheUser(userModel);
      await _syncCurrencyToPrefs(userModel.currency);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forceLogout() async {
    try {
      await localDataSource.clearAuthData();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearAuthData();
      return const Right(null);
    } on ServerException catch (e) {
      await localDataSource.clearAuthData();
      return Left(ServerFailure(e.message));
    } catch (e) {
      await localDataSource.clearAuthData();
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> googleLogin({
    required String idToken,
  }) async {
    try {
      final userModel = await remoteDataSource.googleLogin(idToken);
      if (userModel.token != null) {
        await localDataSource.cacheToken(userModel.token!);
      }
      await localDataSource.cacheUser(userModel);
      await _syncCurrencyToPrefs(userModel.currency);
      return Right(userModel);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final cachedUser = await localDataSource.getCachedUser();
      // Try to refresh from backend to get correct subscription_status (fixes stale premium cache)
      try {
        final freshUser = await remoteDataSource.getProfile();
        // Preserve token from cached user if fresh doesn't have it
        final token = cachedUser?.token ?? freshUser.token;
        final userToCache = UserModel(
          id: freshUser.id,
          name: freshUser.name,
          firstName: freshUser.firstName,
          lastName: freshUser.lastName,
          email: freshUser.email,
          phone: freshUser.phone,
          businessName: freshUser.businessName,
          address: freshUser.address,
          city: freshUser.city,
          state: freshUser.state,
          zip: freshUser.zip,
          avatarUrl: freshUser.avatarUrl,
          currency: freshUser.currency,
          token: token,
          subscriptionStatus: freshUser.subscriptionStatus,
          subscriptionExpiry: freshUser.subscriptionExpiry,
          createdAt: freshUser.createdAt,
          updatedAt: freshUser.updatedAt,
          hasPassword: freshUser.hasPassword,
          accountStatus: freshUser.accountStatus,
          blockedAt: freshUser.blockedAt,
          deletionRequestedAt: freshUser.deletionRequestedAt,
        );
        await localDataSource.cacheUser(userToCache);
        await _syncCurrencyToPrefs(userToCache.currency);
        return Right(userToCache);
      } on AuthenticationException catch (e) {
        // Session is invalid or the account has been deleted/blocked.
        // Clear local credentials and propagate the failure so the UI can
        // force a redirect to the login screen.
        await localDataSource.clearAuthData();
        return Left(AuthenticationFailure(e.message));
      } catch (_) {
        // If backend fetch fails for any other reason (offline/server error),
        // return cached user and sync its currency to prefs.
        if (cachedUser != null) {
          await _syncCurrencyToPrefs(cachedUser.currency);
        }
        return Right(cachedUser);
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      await remoteDataSource.verifyOtp(email: email, code: code);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendOtp({required String email}) async {
    try {
      await remoteDataSource.resendOtp(email: email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async {
    try {
      await remoteDataSource.resetPassword(email: email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
