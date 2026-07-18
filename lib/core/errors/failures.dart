import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

class DuplicateFailure extends Failure {
  final Map<String, dynamic>? existingExpense;
  const DuplicateFailure(super.message, {this.existingExpense});

  @override
  List<Object> get props => [message, if (existingExpense != null) existingExpense!];
}

class LimitExceededFailure extends Failure {
  final String code; // SCAN_LIMIT_EXCEEDED or MANUAL_LIMIT_EXCEEDED
  final Map<String, dynamic>? usage;

  const LimitExceededFailure(
    super.message, {
    required this.code,
    this.usage,
  });

  bool get isScanLimit => code == 'SCAN_LIMIT_EXCEEDED';
  bool get isManualLimit => code == 'MANUAL_LIMIT_EXCEEDED';

  @override
  List<Object> get props => [message, code, if (usage != null) usage!];
}
