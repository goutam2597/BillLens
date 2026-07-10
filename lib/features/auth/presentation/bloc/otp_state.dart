import 'package:equatable/equatable.dart';

abstract class OtpState extends Equatable {
  const OtpState();

  @override
  List<Object?> get props => [];
}

class OtpInitial extends OtpState {
  const OtpInitial();
}

class OtpLoading extends OtpState {
  const OtpLoading();
}

class OtpVerified extends OtpState {
  final String message;

  const OtpVerified({this.message = 'Verified successfully'});

  @override
  List<Object> get props => [message];
}

class OtpResent extends OtpState {
  final String message;

  const OtpResent({this.message = 'OTP resent'});

  @override
  List<Object> get props => [message];
}

class OtpError extends OtpState {
  final String message;

  const OtpError(this.message);

  @override
  List<Object> get props => [message];
}
