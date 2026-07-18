import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/usecases/request_deletion_usecase.dart';
import '../../domain/usecases/get_deletion_status_usecase.dart';
import '../../domain/usecases/cancel_deletion_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository _authRepository;
  final RequestDeletionUseCase _requestDeletion;
  final GetDeletionStatusUseCase _getDeletionStatus;
  final CancelDeletionUseCase _cancelDeletion;

  ProfileBloc({
    required AuthRepository authRepository,
    required RequestDeletionUseCase requestDeletionUseCase,
    required GetDeletionStatusUseCase getDeletionStatusUseCase,
    required CancelDeletionUseCase cancelDeletionUseCase,
  })  : _authRepository = authRepository,
        _requestDeletion = requestDeletionUseCase,
        _getDeletionStatus = getDeletionStatusUseCase,
        _cancelDeletion = cancelDeletionUseCase,
        super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<LogoutRequested>(_onLogoutRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
    on<RequestDeleteAccount>(_onRequestDeleteAccount);
    on<CancelDeleteRequest>(_onCancelDeleteRequest);
    on<LoadDeletionStatus>(_onLoadDeletionStatus);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _authRepository.getCurrentUser();

    // Load deletion status separately to avoid async inside fold
    Map<String, dynamic>? deletionData;
    try {
      final delResult = await _getDeletionStatus(const NoParams());
      delResult.fold(
        (l) => deletionData = null,
        (r) => deletionData = r,
      );
    } catch (_) {
      deletionData = null;
    }

    if (emit.isDone) return;

    result.fold(
      (failure) {
        if (failure is AuthenticationFailure ||
            _isSessionInvalidMessage(failure.message)) {
          emit(ProfileSessionInvalid(failure.message));
        } else {
          emit(ProfileError(failure.message));
        }
      },
      (user) {
        if (user == null) {
          emit(const ProfileSessionInvalid('No user found'));
          return;
        }
        if (user.accountStatus == 'blocked' || user.blockedAt != null) {
          emit(const ProfileSessionInvalid('Account blocked'));
          return;
        }
        emit(ProfileLoaded(user: user, deletionStatus: deletionData));
      },
    );
  }

  bool _isSessionInvalidMessage(String message) {
    final lower = message.toLowerCase();
    return lower.contains('user not found') ||
        lower.contains('not found') ||
        lower.contains('invalid token') ||
        lower.contains('unauthenticated') ||
        lower.contains('unauthorized') ||
        lower.contains('account blocked');
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

  // Old direct delete - now redirects to request flow
  Future<void> _onDeleteAccountRequested(
    DeleteAccountRequested event,
    Emitter<ProfileState> emit,
  ) async {
    // Instead of logout, request deletion
    if (event.reason != null) {
      add(RequestDeleteAccount(reason: event.reason));
    } else {
      // If no reason, just load deletion status to show dialog
      add(LoadDeletionStatus());
    }
  }

  Future<void> _onRequestDeleteAccount(
    RequestDeleteAccount event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _requestDeletion(event.reason);
    result.fold(
      (failure) => emit(DeletionError(failure.message)),
      (data) => emit(DeletionRequested(data)),
    );
  }

  Future<void> _onCancelDeleteRequest(
    CancelDeleteRequest event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _cancelDeletion(const NoParams());
    result.fold(
      (failure) => emit(DeletionError(failure.message)),
      (_) => emit(const DeletionCancelled()),
    );
  }

  Future<void> _onLoadDeletionStatus(
    LoadDeletionStatus event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await _getDeletionStatus(const NoParams());
    result.fold(
      (failure) => emit(DeletionError(failure.message)),
      (data) => emit(DeletionStatusLoaded(data)),
    );
  }
}
