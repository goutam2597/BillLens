import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/account_deletion_repository.dart';

@lazySingleton
class RequestDeletionUseCase implements UseCase<Map<String, dynamic>, String?> {
  final AccountDeletionRepository repository;
  RequestDeletionUseCase(this.repository);
  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String? reason) {
    return repository.requestDeletion(reason: reason);
  }
}
