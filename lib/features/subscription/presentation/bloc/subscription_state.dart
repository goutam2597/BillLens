import 'package:equatable/equatable.dart';

class Plan extends Equatable {
  final String id;
  final String name;
  final double price;
  final List<String> features;
  final int scanLimit;

  const Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.features,
    required this.scanLimit,
  });

  @override
  List<Object> get props => [id, name, price, features, scanLimit];
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

  const SubscriptionLoaded({
    required this.plans,
    this.currentPlanId = 'free',
  });

  bool get isPremium => currentPlanId == 'premium';

  @override
  List<Object> get props => [plans, currentPlanId];
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
