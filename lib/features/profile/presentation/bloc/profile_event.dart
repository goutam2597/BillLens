import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final String? name;
  final String? email;
  final String? businessName;
  final String? currency;

  const UpdateProfile({this.name, this.email, this.businessName, this.currency});

  @override
  List<Object?> get props => [name, email, businessName, currency];
}

class LogoutRequested extends ProfileEvent {}

class DeleteAccountRequested extends ProfileEvent {}
