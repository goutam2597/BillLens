import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/local/local_storage_service.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

@injectable
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final LocalStorageService _storage;

  SubscriptionBloc({required LocalStorageService storage})
      : _storage = storage,
        super(const SubscriptionInitial()) {
    on<LoadPlans>(_onLoadPlans);
    on<PurchasePlan>(_onPurchasePlan);
    on<RestorePurchase>(_onRestorePurchase);
    on<VerifySubscription>(_onVerifySubscription);
  }

  Future<void> _onLoadPlans(
    LoadPlans event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final isPremium = _storage.getString('subscription') == 'premium';
    emit(SubscriptionLoaded(
      plans: const [
        Plan(
          id: 'free',
          name: 'Free',
          price: 0,
          features: [
            '10 scans/month',
            'Basic reports',
            'Limited AI insights',
          ],
          scanLimit: 10,
        ),
        Plan(
          id: 'premium',
          name: 'Premium',
          price: 9.99,
          features: [
            'Unlimited scans',
            'AI-powered categorization',
            'Advanced reports',
            'No ads',
            'Cloud backup',
            'Priority support',
          ],
          scanLimit: 999999,
        ),
      ],
      currentPlanId: isPremium ? 'premium' : 'free',
    ));
  }

  Future<void> _onPurchasePlan(
    PurchasePlan event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    await Future<void>.delayed(const Duration(seconds: 1));
    await _storage.setString('subscription', event.planId);
    emit(SubscriptionPurchased(event.planId));
  }

  Future<void> _onRestorePurchase(
    RestorePurchase event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    await Future<void>.delayed(const Duration(seconds: 1));
    emit(const SubscriptionPurchased('premium'));
  }

  Future<void> _onVerifySubscription(
    VerifySubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    add(LoadPlans());
  }
}
