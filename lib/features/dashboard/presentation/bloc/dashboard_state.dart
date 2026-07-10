import 'package:equatable/equatable.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final UserEntity? user;
  final double monthlyTotal;
  final int expenseCount;
  final List<Expense> recentExpenses;
  final int pendingSyncCount;
  final bool isOnline;

  const DashboardLoaded({
    this.user,
    required this.monthlyTotal,
    required this.expenseCount,
    required this.recentExpenses,
    this.pendingSyncCount = 0,
    this.isOnline = false,
  });

  String get displayName => user?.displayName ?? 'User';

  DashboardLoaded copyWith({
    UserEntity? user,
    double? monthlyTotal,
    int? expenseCount,
    List<Expense>? recentExpenses,
    int? pendingSyncCount,
    bool? isOnline,
  }) {
    return DashboardLoaded(
      user: user ?? this.user,
      monthlyTotal: monthlyTotal ?? this.monthlyTotal,
      expenseCount: expenseCount ?? this.expenseCount,
      recentExpenses: recentExpenses ?? this.recentExpenses,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  List<Object?> get props => [
        user,
        monthlyTotal,
        expenseCount,
        recentExpenses,
        pendingSyncCount,
        isOnline,
      ];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object> get props => [message];
}
