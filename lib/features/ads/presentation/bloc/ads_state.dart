import 'package:equatable/equatable.dart';

abstract class AdsState extends Equatable {
  const AdsState();
  @override
  List<Object?> get props => [];
}

class AdsInitial extends AdsState {
  const AdsInitial();
}

class AdsLoaded extends AdsState {
  final bool showAds;
  final bool isPremium;

  const AdsLoaded({required this.showAds, required this.isPremium});

  @override
  List<Object> get props => [showAds, isPremium];
}

class AdsHidden extends AdsState {
  const AdsHidden();
}

class AdsError extends AdsState {
  final String message;
  const AdsError(this.message);
  @override
  List<Object> get props => [message];
}
