import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) async {
    return await repository.register(
      name: params.name,
      email: params.email,
      password: params.password,
      businessName: params.businessName,
      currency: params.currency,
    );
  }
}

class RegisterParams extends Equatable {
  final String name;
  final String email;
  final String password;
  final String? businessName;
  final String currency;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    this.businessName,
    required this.currency,
  });

  @override
  List<Object?> get props => [name, email, password, businessName, currency];
}
