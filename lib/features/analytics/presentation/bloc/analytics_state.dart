import 'package:equatable/equatable.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();
  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

class AnalyticsLoaded extends AnalyticsState {
  final double totalSpending;
  final double avgDaily;
  final int totalExpenses;
  final int receiptCount;
  final String currency;
  final String topCategory;
  final List<double> weeklyValues;
  final List<String> chartLabels;
  final List<CategoryBreakdown> categoryDistribution;
  final DateTime startDate;
  final DateTime endDate;
  final bool isOnline;
  final double businessPercentage;
  final double personalPercentage;

  const AnalyticsLoaded({
    required this.totalSpending,
    required this.avgDaily,
    required this.totalExpenses,
    required this.receiptCount,
    required this.currency,
    required this.topCategory,
    required this.weeklyValues,
    required this.chartLabels,
    required this.categoryDistribution,
    required this.startDate,
    required this.endDate,
    required this.isOnline,
    this.businessPercentage = 0,
    this.personalPercentage = 0,
  });

  @override
  List<Object?> get props => [
        totalSpending,
        avgDaily,
        totalExpenses,
        receiptCount,
        currency,
        topCategory,
        weeklyValues,
        chartLabels,
        categoryDistribution,
        startDate,
        endDate,
        isOnline,
        businessPercentage,
        personalPercentage,
      ];
}

class AnalyticsError extends AnalyticsState {
  final String message;
  const AnalyticsError(this.message);
  @override
  List<Object> get props => [message];
}

class CategoryBreakdown extends Equatable {
  final String name;
  final double amount;
  final double percentage;
  final String color;

  const CategoryBreakdown({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  @override
  List<Object> get props => [name, amount, percentage, color];
}
