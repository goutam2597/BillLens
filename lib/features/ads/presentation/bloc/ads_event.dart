import 'package:equatable/equatable.dart';

abstract class AdsEvent extends Equatable {
  const AdsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAds extends AdsEvent {}

class ShowBannerAd extends AdsEvent {}

class ShowNativeAd extends AdsEvent {}

class ShowRewardedAd extends AdsEvent {}

class HideAds extends AdsEvent {}
