import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    String? businessName,
    required String currency,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, void>> verifyOtp({
    required String email,
    required String code,
  });

  Future<Either<Failure, void>> resendOtp({required String email});

  Future<Either<Failure, void>> resetPassword({required String email});
}
