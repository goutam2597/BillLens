import 'package:equatable/equatable.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAnalytics extends AnalyticsEvent {
  const LoadAnalytics();
}

class ChangeAnalyticsDateRange extends AnalyticsEvent {
  final DateTime start;
  final DateTime end;
  const ChangeAnalyticsDateRange({required this.start, required this.end});
  @override
  List<Object> get props => [start, end];
}

class AnalyticsConnectivityChanged extends AnalyticsEvent {
  final bool isOnline;
  const AnalyticsConnectivityChanged(this.isOnline);

  @override
  List<Object> get props => [isOnline];
}

class AnalyticsDataChanged extends AnalyticsEvent {
  const AnalyticsDataChanged();
}
