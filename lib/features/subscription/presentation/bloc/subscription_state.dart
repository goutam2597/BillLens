import 'package:equatable/equatable.dart';

class Plan extends Equatable {
  final String id;
  final String name;
  final double price;
  final List<String> features;
  final int scanLimit;
  final int manualLimit;

  const Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.features,
    required this.scanLimit,
    this.manualLimit = 20,
  });

  @override
  List<Object> get props => [id, name, price, features, scanLimit, manualLimit];
}

/// Usage data from backend GET /subscription/usage
class UsageInfo extends Equatable {
  final bool isPremium;
  final int scansUsed;
  final int scansLimit;
  final int scansRemaining;
  final int manualUsed;
  final int manualLimit;
  final int manualRemaining;
  final String resetsAt;
  final String currentMonth;
  final bool isFixed;

  const UsageInfo({
    this.isPremium = false,
    this.scansUsed = 0,
    this.scansLimit = 10,
    this.scansRemaining = 10,
    this.manualUsed = 0,
    this.manualLimit = 20,
    this.manualRemaining = 20,
    this.resetsAt = '',
    this.currentMonth = '',
    this.isFixed = true,
  });

  factory UsageInfo.fromJson(Map<String, dynamic> json) {
    try {
      final scans = json['scans'] as Map<String, dynamic>?;
      final manual = json['manual_expenses'] as Map<String, dynamic>?;
      return UsageInfo(
        isPremium: json['is_premium'] as bool? ?? false,
        scansUsed: (scans?['used'] as int?) ?? (json['scans_used'] as int? ?? 0),
        scansLimit: (scans?['limit'] as int?) ?? (json['scans_limit'] as int? ?? 10),
        scansRemaining: (scans?['remaining'] as int?) ?? (json['scans_remaining'] as int? ?? 0),
        manualUsed: (manual?['used'] as int?) ?? (json['manual_used'] as int? ?? 0),
        manualLimit: (manual?['limit'] as int?) ?? (json['manual_limit'] as int? ?? 20),
        manualRemaining: (manual?['remaining'] as int?) ?? (json['manual_remaining'] as int? ?? 0),
        resetsAt: json['resets_at'] as String? ?? '',
        currentMonth: json['current_month'] as String? ?? '',
        isFixed: json['limits_fixed'] as bool? ?? true,
      );
    } catch (_) {
      return const UsageInfo();
    }
  }

  double get scansProgress => scansLimit > 0 ? scansUsed / scansLimit : 0;
  double get manualProgress => manualLimit > 0 ? manualUsed / manualLimit : 0;

  bool get isScansExhausted => !isPremium && scansRemaining <= 0;
  bool get isManualExhausted => !isPremium && manualRemaining <= 0;
  bool get isAnyExhausted => isScansExhausted || isManualExhausted;

  @override
  List<Object> get props => [
        isPremium,
        scansUsed,
        scansLimit,
        scansRemaining,
        manualUsed,
        manualLimit,
        manualRemaining,
        resetsAt,
        currentMonth,
        isFixed,
      ];
}

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();
  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

class SubscriptionLoaded extends SubscriptionState {
  final List<Plan> plans;
  final String currentPlanId;
  final UsageInfo? usage;

  const SubscriptionLoaded({
    required this.plans,
    this.currentPlanId = 'free',
    this.usage,
  });

  bool get isPremium => currentPlanId == 'premium' || (usage?.isPremium ?? false);

  SubscriptionLoaded copyWith({
    List<Plan>? plans,
    String? currentPlanId,
    UsageInfo? usage,
  }) {
    return SubscriptionLoaded(
      plans: plans ?? this.plans,
      currentPlanId: currentPlanId ?? this.currentPlanId,
      usage: usage ?? this.usage,
    );
  }

  @override
  List<Object?> get props => [plans, currentPlanId, usage];
}

class SubscriptionPurchased extends SubscriptionState {
  final String planId;
  const SubscriptionPurchased(this.planId);
  @override
  List<Object> get props => [planId];
}

class SubscriptionError extends SubscriptionState {
  final String message;
  const SubscriptionError(this.message);
  @override
  List<Object> get props => [message];
}
