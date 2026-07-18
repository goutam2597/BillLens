import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class AccountDeletionRepository {
  Future<Either<Failure, Map<String, dynamic>>> requestDeletion({String? reason});
  Future<Either<Failure, Map<String, dynamic>?>> getDeletionStatus();
  Future<Either<Failure, void>> cancelDeletion();
}
