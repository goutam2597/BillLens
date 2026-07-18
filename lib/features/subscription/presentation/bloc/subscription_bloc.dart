import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/local/local_storage_service.dart';
import '../../../expenses/data/datasources/expense_local_data_source.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

@injectable
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final LocalStorageService _storage;
  final Dio _dio;
  final ExpenseLocalDataSource _expenseLocal;

  SubscriptionBloc({
    required LocalStorageService storage,
    @Named('dio') required Dio dio,
    required ExpenseLocalDataSource expenseLocalDataSource,
  })  : _storage = storage,
        _dio = dio,
        _expenseLocal = expenseLocalDataSource,
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

    // Try to fetch usage from backend (source of truth) + local counts as fallback
    UsageInfo? usage;
    bool isPremiumFromStorage = _storage.getString('subscription') == 'premium';

    try {
      // Backend usage — requires auth token, dio interceptor adds it
      final response = await _dio.get('/api/subscription/usage');
      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>?;
        if (data != null) {
          usage = UsageInfo.fromJson(data);
          isPremiumFromStorage = usage.isPremium;
        }
      }
    } catch (_) {
      // Fallback to local counting for offline UX
      try {
        final localUsage = await _expenseLocal.getMonthlyUsage();
        usage = UsageInfo(
          isPremium: isPremiumFromStorage,
          scansUsed: localUsage['scanned'] ?? 0,
          scansLimit: isPremiumFromStorage ? 300 : 10,
          scansRemaining: isPremiumFromStorage ? (300 - (localUsage['scanned'] ?? 0)).clamp(0, 300) : (10 - (localUsage['scanned'] ?? 0)).clamp(0, 10),
          manualUsed: localUsage['manual'] ?? 0,
          manualLimit: isPremiumFromStorage ? 999999 : 20,
          manualRemaining: isPremiumFromStorage ? 999999 : (20 - (localUsage['manual'] ?? 0)).clamp(0, 20),
          currentMonth: DateTime.now().toIso8601String().substring(0, 7),
          resetsAt: DateTime(DateTime.now().year, DateTime.now().month + 1, 1).toIso8601String(),
          isFixed: true,
        );
      } catch (_) {
        // ignore
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 300));

    emit(SubscriptionLoaded(
      plans: const [
        Plan(
          id: 'free',
          name: 'Free',
          price: 0,
          features: [
            '10 AI receipt scans/month (fixed)',
            '20 manual expenses/month (fixed)',
            'Basic reports',
            'Limited AI insights',
          ],
          scanLimit: 10,
          manualLimit: 20,
        ),
        Plan(
          id: 'premium',
          name: 'Premium',
          price: 9.99,
          features: [
            '300 AI receipt scans/month (fixed)',
            'Unlimited manual expenses (no AI usage)',
            'AI-powered categorization',
            'Advanced reports',
            'No ads',
            'Cloud backup',
            'Priority support',
          ],
          scanLimit: 300,
          manualLimit: 999999,
        ),
      ],
      currentPlanId: isPremiumFromStorage ? 'premium' : 'free',
      usage: usage,
    ));
  }

  Future<void> _onPurchasePlan(
    PurchasePlan event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    try {
      final response = await _dio.post('/api/subscribe', data: {'plan_id': event.planId});
      if (response.statusCode == 200) {
        await _storage.setString('subscription', event.planId);
        emit(SubscriptionPurchased(event.planId));
        add(LoadPlans());
        return;
      }
    } catch (_) {}
    await _storage.setString('subscription', event.planId);
    emit(SubscriptionPurchased(event.planId));
    // Reload plans to get updated usage
    add(LoadPlans());
  }

  Future<void> _onRestorePurchase(
    RestorePurchase event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    try {
      final response = await _dio.get('/api/subscription/usage');
      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>?;
        if (data != null) {
          final usage = UsageInfo.fromJson(data);
          if (usage.isPremium) {
            await _storage.setString('subscription', 'premium');
            emit(const SubscriptionPurchased('premium'));
            add(LoadPlans());
            return;
          } else {
            await _storage.setString('subscription', 'free');
            emit(const SubscriptionError('No premium subscription found. You are on free plan (10 scans + 20 manual fixed).'));
            add(LoadPlans());
            return;
          }
        }
      }
    } catch (_) {}
    emit(const SubscriptionError('Failed to restore. Please check internet and ensure you have an active premium subscription.'));
    add(LoadPlans());
  }

  Future<void> _onVerifySubscription(
    VerifySubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    add(LoadPlans());
  }
}
