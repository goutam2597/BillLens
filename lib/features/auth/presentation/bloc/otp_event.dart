import 'package:equatable/equatable.dart';

abstract class OtpEvent extends Equatable {
  const OtpEvent();

  @override
  List<Object?> get props => [];
}

class VerifyOtpRequested extends OtpEvent {
  final String email;
  final String code;

  const VerifyOtpRequested({required this.email, required this.code});

  @override
  List<Object> get props => [email, code];
}

class ResendOtpRequested extends OtpEvent {
  final String email;

  const ResendOtpRequested({required this.email});

  @override
  List<Object> get props => [email];
}
