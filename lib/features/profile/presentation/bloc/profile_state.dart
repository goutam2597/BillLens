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

  const ProfileLoaded({
    required this.user,
    this.subscriptionStatus = 'free',
  });

  @override
  List<Object> get props => [user, subscriptionStatus];
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
