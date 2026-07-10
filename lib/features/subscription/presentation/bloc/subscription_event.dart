import 'package:equatable/equatable.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();
  @override
  List<Object?> get props => [];
}

class LoadPlans extends SubscriptionEvent {}

class PurchasePlan extends SubscriptionEvent {
  final String planId;
  const PurchasePlan(this.planId);
  @override
  List<Object> get props => [planId];
}

class RestorePurchase extends SubscriptionEvent {}

class VerifySubscription extends SubscriptionEvent {}
