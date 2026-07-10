import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/auth_repository.dart';
import 'otp_event.dart';
import 'otp_state.dart';

@injectable
class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final AuthRepository _authRepository;

  OtpBloc(this._authRepository) : super(const OtpInitial()) {
    on<VerifyOtpRequested>(_onVerifyOtp);
    on<ResendOtpRequested>(_onResendOtp);
  }

  Future<void> _onVerifyOtp(
    VerifyOtpRequested event,
    Emitter<OtpState> emit,
  ) async {
    emit(const OtpLoading());
    await Future<void>.delayed(const Duration(seconds: 1));
    final result = await _authRepository.verifyOtp(
      email: event.email,
      code: event.code,
    );
    result.fold(
      (failure) => emit(OtpError(failure.message)),
      (_) => emit(const OtpVerified()),
    );
  }

  Future<void> _onResendOtp(
    ResendOtpRequested event,
    Emitter<OtpState> emit,
  ) async {
    emit(const OtpLoading());
    await Future<void>.delayed(const Duration(seconds: 1));
    final result = await _authRepository.resendOtp(email: event.email);
    result.fold(
      (failure) => emit(OtpError(failure.message)),
      (_) => emit(const OtpResent()),
    );
  }
}
