import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserEntity user;
  final String subscriptionStatus;
  final Map<String, dynamic>? deletionStatus;

  const ProfileLoaded({
    required this.user,
    this.subscriptionStatus = 'free',
    this.deletionStatus,
  });

  @override
  List<Object> get props => [user, subscriptionStatus, deletionStatus ?? {}];
}

class ProfileUpdated extends ProfileState {
  final UserEntity user;
  const ProfileUpdated(this.user);
  @override
  List<Object> get props => [user];
}

class ProfileLoggedOut extends ProfileState {
  const ProfileLoggedOut();
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object> get props => [message];
}

// Deletion request states
class DeletionRequested extends ProfileState {
  final Map<String, dynamic> data;
  const DeletionRequested(this.data);
  @override
  List<Object> get props => [data];
}

class DeletionStatusLoaded extends ProfileState {
  final Map<String, dynamic>? data;
  const DeletionStatusLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class DeletionCancelled extends ProfileState {
  const DeletionCancelled();
}

class DeletionError extends ProfileState {
  final String message;
  const DeletionError(this.message);
  @override
  List<Object> get props => [message];
}
