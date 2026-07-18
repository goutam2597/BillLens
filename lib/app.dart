import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/local/currency_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/expenses/presentation/bloc/expense_bloc.dart';
import 'features/analytics/presentation/bloc/analytics_bloc.dart';
import 'features/analytics/presentation/bloc/analytics_event.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/bloc/profile_event.dart';

class BillLensApp extends StatelessWidget {
  const BillLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure currency service is initialized and listening to auth changes
    try { getIt<CurrencyService>(); } catch (_) {}
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>()..add(CheckAuthStatus()),
        ),
        BlocProvider<DashboardBloc>(
          create: (context) => getIt<DashboardBloc>(),
        ),
        BlocProvider<ExpenseBloc>(
          create: (context) =>
              getIt<ExpenseBloc>()..add(const LoadExpensesRequested()),
        ),
        BlocProvider<AnalyticsBloc>(
          create: (context) =>
              getIt<AnalyticsBloc>()..add(const LoadAnalytics()),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => getIt<ProfileBloc>()
            ..add(LoadProfile())
            ..add(LoadDeletionStatus()),
        ),
      ],
      child: MaterialApp.router(
        title: 'BillLens',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
