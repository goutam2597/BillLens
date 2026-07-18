import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/account_deletion_repository.dart';

@lazySingleton
class GetDeletionStatusUseCase implements UseCase<Map<String, dynamic>?, NoParams> {
  final AccountDeletionRepository repository;
  GetDeletionStatusUseCase(this.repository);
  @override
  Future<Either<Failure, Map<String, dynamic>?>> call(NoParams params) {
    return repository.getDeletionStatus();
  }
}
