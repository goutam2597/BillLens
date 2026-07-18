import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String? businessName;
  final String currency;

  const RegisterEvent({
    required this.name,
    required this.email,
    required this.password,
    this.businessName,
    required this.currency,
  });

  @override
  List<Object?> get props => [name, email, password, businessName, currency];
}

class LogoutEvent extends AuthEvent {}

/// Clears local auth state immediately without calling the backend.
/// Use this when the backend has already told us the session is invalid.
class ForceLogoutEvent extends AuthEvent {}

class GoogleLoginEvent extends AuthEvent {
  final String idToken;

  const GoogleLoginEvent({required this.idToken});

  @override
  List<Object> get props => [idToken];
}
