import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/local/local_storage_service.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final AuthRepository _authRepository;
  final LocalStorageService _storageService;

  SplashBloc({
    required AuthRepository authRepository,
    required LocalStorageService storageService,
  })  : _authRepository = authRepository,
        _storageService = storageService,
        super(const SplashInitial()) {
    on<AppStarted>(_onAppStarted);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<CheckOnboardingStatus>(_onCheckOnboardingStatus);
  }

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    final onboardingComplete = _storageService.onboardingComplete;
    if (!onboardingComplete) {
      emit(const SplashFirstTimeUser());
      return;
    }
    add(CheckAuthStatus());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());
    final result = await _authRepository.getCurrentUser();
    result.fold(
      (_) => emit(const SplashUnauthenticated()),
      (user) {
        if (user != null) {
          emit(const SplashAuthenticated());
        } else {
          emit(const SplashUnauthenticated());
        }
      },
    );
  }

  Future<void> _onCheckOnboardingStatus(
    CheckOnboardingStatus event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());
    final onboardingComplete = _storageService.onboardingComplete;
    if (onboardingComplete) {
      emit(const SplashAuthenticated());
    } else {
      emit(const SplashFirstTimeUser());
    }
  }
}
