import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/account_deletion_repository.dart';

@lazySingleton
class CancelDeletionUseCase implements UseCase<void, NoParams> {
  final AccountDeletionRepository repository;
  CancelDeletionUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.cancelDeletion();
  }
}
