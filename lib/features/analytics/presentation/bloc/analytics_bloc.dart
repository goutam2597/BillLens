import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/connectivity_service.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../expenses/presentation/bloc/expense_change_notifier.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

@injectable
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final ExpenseRepository _expenseRepository;
  final ConnectivityService _connectivity;
  final Dio _dio;
  final ExpenseChangeNotifier _changeNotifier;
  late final StreamSubscription<bool> _connectivitySubscription;
  late final StreamSubscription<ExpenseChangeEvent> _changesSubscription;
  DateTime? _startDate;
  DateTime? _endDate;

  AnalyticsBloc({
    required ExpenseRepository expenseRepository,
    required ConnectivityService connectivityService,
    @Named('dio') required Dio dio,
    required ExpenseChangeNotifier changeNotifier,
  })  : _expenseRepository = expenseRepository,
        _connectivity = connectivityService,
        _dio = dio,
        _changeNotifier = changeNotifier,
        super(const AnalyticsInitial()) {
    on<LoadAnalytics>(_onLoadAnalytics);
    on<ChangeAnalyticsDateRange>(_onChangeDateRange);
    on<AnalyticsConnectivityChanged>(_onConnectivityChanged);
    on<AnalyticsDataChanged>(_onDataChanged);
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (online) => add(AnalyticsConnectivityChanged(online)),
    );
    _changesSubscription = _changeNotifier.stream.listen(
      (event) => add(const AnalyticsDataChanged()),
    );
  }

  Future<void> _onLoadAnalytics(
    LoadAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    final range = _resolveRange();
    final online = await _connectivity.isOnline;

    if (online) {
      await _expenseRepository.syncPendingExpenses();
      try {
        final response = await _dio.get<Map<String, dynamic>>(
          '/api/analytics',
          queryParameters: {
            'start_date': _dateParam(range.$1),
            'end_date': _dateParam(range.$2),
          },
        );
        final data = response.data?['data'] as Map<String, dynamic>;
        emit(_fromRemote(data, range.$1, range.$2));
        return;
      } catch (_) {
        // The local cache remains the source of truth when the API is unavailable.
      }
    }

    final result = await _expenseRepository.getExpenses();
    result.fold(
      (failure) => emit(AnalyticsError(failure.message)),
      (expenses) => emit(_fromLocal(expenses, range.$1, range.$2, online)),
    );
  }

  Future<void> _onChangeDateRange(
    ChangeAnalyticsDateRange event,
    Emitter<AnalyticsState> emit,
  ) async {
    _startDate = event.start;
    _endDate = event.end;
    add(const LoadAnalytics());
  }

  Future<void> _onConnectivityChanged(
    AnalyticsConnectivityChanged event,
    Emitter<AnalyticsState> emit,
  ) async {
    if (event.isOnline) add(const LoadAnalytics());
  }

  AnalyticsLoaded _fromRemote(
    Map<String, dynamic> data,
    DateTime start,
    DateTime end,
  ) {
    final daily = (data['daily_spending'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final categories = (data['categories'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final total = (data['total_spending'] as num?)?.toDouble() ?? 0;
    final dailyAmounts = {
      for (final row in daily)
        DateTime.parse(row['date'] as String):
            (row['amount'] as num?)?.toDouble() ?? 0,
    };
    final effectiveStart = dailyAmounts.isEmpty
        ? end
        : dailyAmounts.keys
            .reduce((first, date) => date.isBefore(first) ? date : first);
    return _buildLoaded(
      total: total,
      totalExpenses: (data['total_expenses'] as num?)?.toInt() ?? 0,
      receiptCount: (data['receipt_count'] as num?)?.toInt() ?? 0,
      currency: data['currency'] as String? ?? 'USD',
      dailyAmounts: dailyAmounts,
      categoryAmounts: {
        for (final row in categories)
          row['name'] as String: (row['amount'] as num?)?.toDouble() ?? 0,
      },
      start: start.millisecondsSinceEpoch == 0 ? effectiveStart : start,
      end: end,
      isOnline: true,
    );
  }

  AnalyticsLoaded _fromLocal(
    List<Expense> expenses,
    DateTime start,
    DateTime end,
    bool isOnline,
  ) {
    final filtered = expenses.where((expense) {
      final date =
          DateTime(expense.date.year, expense.date.month, expense.date.day);
      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();
    final daily = <DateTime, double>{};
    final categories = <String, double>{};
    for (final expense in filtered) {
      final date =
          DateTime(expense.date.year, expense.date.month, expense.date.day);
      daily[date] = (daily[date] ?? 0) + expense.amount;
      final category = expense.categoryName ?? 'Uncategorized';
      categories[category] = (categories[category] ?? 0) + expense.amount;
    }
    final effectiveStart = filtered.isEmpty
        ? end
        : filtered
            .map((expense) => DateTime(
                  expense.date.year,
                  expense.date.month,
                  expense.date.day,
                ))
            .reduce((first, date) => date.isBefore(first) ? date : first);
    return _buildLoaded(
      total: filtered.fold(0, (sum, expense) => sum + expense.amount),
      totalExpenses: filtered.length,
      receiptCount: filtered
          .where((expense) =>
              (expense.receiptImageLocalPath?.isNotEmpty ?? false) ||
              (expense.receiptImageRemoteUrl?.isNotEmpty ?? false))
          .length,
      currency: filtered.isEmpty ? 'USD' : filtered.first.currency,
      dailyAmounts: daily,
      categoryAmounts: categories,
      start: start.millisecondsSinceEpoch == 0 ? effectiveStart : start,
      end: end,
      isOnline: isOnline,
    );
  }

  AnalyticsLoaded _buildLoaded({
    required double total,
    required int totalExpenses,
    required int receiptCount,
    required String currency,
    required Map<DateTime, double> dailyAmounts,
    required Map<String, double> categoryAmounts,
    required DateTime start,
    required DateTime end,
    required bool isOnline,
  }) {
    const colors = ['#7C3AED', '#2563EB', '#10B981', '#F59E0B', '#64748B'];
    final sortedCategories = categoryAmounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final categories = sortedCategories.take(5).toList();
    final buckets = _buildBuckets(start, end, dailyAmounts);
    final days = end.difference(start).inDays + 1;
    return AnalyticsLoaded(
      totalSpending: total,
      avgDaily: days > 0 ? total / days : 0,
      totalExpenses: totalExpenses,
      receiptCount: receiptCount,
      currency: currency,
      topCategory: categories.isEmpty ? 'None' : categories.first.key,
      weeklyValues: buckets.$1,
      chartLabels: buckets.$2,
      categoryDistribution: categories.asMap().entries.map((entry) {
        return CategoryBreakdown(
          name: entry.value.key,
          amount: entry.value.value,
          percentage: total > 0 ? entry.value.value / total : 0,
          color: colors[entry.key % colors.length],
        );
      }).toList(),
      startDate: start,
      endDate: end,
      isOnline: isOnline,
    );
  }

  (List<double>, List<String>) _buildBuckets(
    DateTime start,
    DateTime end,
    Map<DateTime, double> dailyAmounts,
  ) {
    final dayCount = end.difference(start).inDays + 1;
    final values = List<double>.filled(7, 0);
    final labels = List<String>.filled(7, '');
    if (dayCount <= 7) {
      for (var index = 0; index < dayCount; index++) {
        final day = start.add(Duration(days: index));
        values[index] = dailyAmounts[day] ?? 0;
        labels[index] = dayCount == 1 ? 'Today' : DateFormat('E').format(day);
      }
      return (values, labels);
    }
    for (var index = 0; index < 7; index++) {
      final bucketStartOffset = (index * dayCount / 7).floor();
      final bucketEndOffset = (((index + 1) * dayCount / 7).floor() - 1)
          .clamp(bucketStartOffset, dayCount - 1);
      final bucketStart = start.add(Duration(days: bucketStartOffset));
      final bucketEnd = start.add(Duration(days: bucketEndOffset));
      labels[index] = dayCount <= 7
          ? DateFormat('E').format(bucketStart)
          : DateFormat('d MMM').format(bucketStart);
      for (var day = bucketStart;
          !day.isAfter(bucketEnd);
          day = day.add(const Duration(days: 1))) {
        values[index] += dailyAmounts[day] ?? 0;
      }
    }
    return (values, labels);
  }

  (DateTime, DateTime) _resolveRange() {
    if (_startDate != null && _endDate != null) return (_startDate!, _endDate!);
    final now = DateTime.now();
    return (
      DateTime.fromMillisecondsSinceEpoch(0),
      DateTime(now.year, now.month, now.day)
    );
  }

  String _dateParam(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Future<void> _onDataChanged(
    AnalyticsDataChanged event,
    Emitter<AnalyticsState> emit,
  ) async {
    // Reload analytics when an expense changes elsewhere.
    await _onLoadAnalytics(const LoadAnalytics(), emit);
  }

  @override
  Future<void> close() async {
    await _connectivitySubscription.cancel();
    await _changesSubscription.cancel();
    return super.close();
  }
}
