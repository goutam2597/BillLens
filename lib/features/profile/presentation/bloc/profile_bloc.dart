import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository _authRepository;

  ProfileBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<LogoutRequested>(_onLogoutRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _authRepository.getCurrentUser();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) {
        if (user != null) {
          emit(ProfileLoaded(user: user));
        } else {
          emit(const ProfileError('No user found'));
        }
      },
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _authRepository.getCurrentUser();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) {
        if (user != null) {
          final updated = user.copyWith(
            name: event.name ?? user.name,
            email: event.email ?? user.email,
            businessName: event.businessName ?? user.businessName,
            currency: event.currency ?? user.currency,
          );
          emit(ProfileUpdated(updated));
        } else {
          emit(const ProfileError('No user found'));
        }
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await _authRepository.logout();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(const ProfileLoggedOut()),
    );
  }

  Future<void> _onDeleteAccountRequested(
    DeleteAccountRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await _authRepository.logout();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(const ProfileLoggedOut()),
    );
  }
}
