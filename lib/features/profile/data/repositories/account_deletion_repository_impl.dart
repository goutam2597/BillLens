import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/account_deletion_repository.dart';
import '../datasources/account_deletion_remote_data_source.dart';

@LazySingleton(as: AccountDeletionRepository)
class AccountDeletionRepositoryImpl implements AccountDeletionRepository {
  final AccountDeletionRemoteDataSource remote;
  AccountDeletionRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, Map<String, dynamic>>> requestDeletion({String? reason}) async {
    try {
      final data = await remote.requestDeletion(reason: reason);
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> getDeletionStatus() async {
    try {
      final data = await remote.getDeletionStatus();
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelDeletion() async {
    try {
      await remote.cancelDeletion();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
