import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/local/local_storage_service.dart';
import 'ads_event.dart';
import 'ads_state.dart';

@injectable
class AdsBloc extends Bloc<AdsEvent, AdsState> {
  final LocalStorageService _storage;

  AdsBloc({required LocalStorageService storage})
      : _storage = storage,
        super(const AdsInitial()) {
    on<LoadAds>(_onLoadAds);
    on<ShowBannerAd>(_onShowBannerAd);
    on<ShowNativeAd>(_onShowNativeAd);
    on<ShowRewardedAd>(_onShowRewardedAd);
    on<HideAds>(_onHideAds);
  }

  Future<void> _onLoadAds(
    LoadAds event,
    Emitter<AdsState> emit,
  ) async {
    final isPremium = _storage.getString('subscription') == 'premium';
    emit(AdsLoaded(showAds: !isPremium, isPremium: isPremium));
  }

  Future<void> _onShowBannerAd(
    ShowBannerAd event,
    Emitter<AdsState> emit,
  ) async {
    final isPremium = _storage.getString('subscription') == 'premium';
    if (!isPremium) {
      emit(AdsLoaded(showAds: true, isPremium: false));
    }
  }

  Future<void> _onShowNativeAd(
    ShowNativeAd event,
    Emitter<AdsState> emit,
  ) async {
    final isPremium = _storage.getString('subscription') == 'premium';
    if (!isPremium) {
      emit(AdsLoaded(showAds: true, isPremium: false));
    }
  }

  Future<void> _onShowRewardedAd(
    ShowRewardedAd event,
    Emitter<AdsState> emit,
  ) async {
    final isPremium = _storage.getString('subscription') == 'premium';
    if (!isPremium) {
      emit(AdsLoaded(showAds: true, isPremium: false));
    }
  }

  Future<void> _onHideAds(
    HideAds event,
    Emitter<AdsState> emit,
  ) async {
    emit(const AdsHidden());
  }
}
