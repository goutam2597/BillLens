import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../local/local_storage_service.dart';

// Auth
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/otp_bloc.dart';
import '../../features/auth/data/repositories/user_repository.dart';
import '../network/connectivity_service.dart';

// Expenses
import '../../features/expenses/data/datasources/expense_local_data_source.dart';
import '../../features/expenses/data/datasources/expense_remote_data_source.dart';
import '../../features/expenses/data/repositories/expense_repository_impl.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../features/expenses/domain/usecases/create_expense_usecase.dart';
import '../../features/expenses/domain/usecases/delete_expense_usecase.dart';
import '../../features/expenses/domain/usecases/get_expense_by_id_usecase.dart';
import '../../features/expenses/domain/usecases/get_expenses_usecase.dart';
import '../../features/expenses/domain/usecases/search_expenses_usecase.dart';
import '../../features/expenses/domain/usecases/update_expense_usecase.dart';
import '../../features/expenses/presentation/bloc/expense_bloc.dart';
import '../../features/expenses/presentation/bloc/expense_details_bloc.dart';
import '../../features/expenses/presentation/bloc/expense_form_bloc.dart';

// Categories
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/domain/usecases/category_usecases.dart';
import '../../features/categories/data/datasources/category_local_data_source.dart';
import '../../features/categories/data/datasources/category_remote_data_source.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/presentation/bloc/category_bloc.dart';

// Dashboard
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';

// Splash
import '../../features/splash/presentation/bloc/splash_bloc.dart';

// Onboarding
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart';

// Receipt Scanner
import '../../features/receipt_scanner/presentation/bloc/receipt_scanner_bloc.dart';
import '../../features/receipt_scanner/presentation/bloc/receipt_processing_bloc.dart';

// Analytics
import '../../features/analytics/presentation/bloc/analytics_bloc.dart';

// Reports
import '../../features/reports/presentation/bloc/reports_bloc.dart';

// Subscription
import '../../features/subscription/presentation/bloc/subscription_bloc.dart';

// Profile
import '../../features/profile/presentation/bloc/profile_bloc.dart';

// Settings
import '../../features/settings/presentation/bloc/settings_bloc.dart';

// Sync
import '../../features/sync/presentation/bloc/sync_bloc.dart';

// Ads
import '../../features/ads/presentation/bloc/ads_bloc.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  await getIt.init();

  // LocalStorageService
  if (!getIt.isRegistered<LocalStorageService>()) {
    final prefs = await SharedPreferences.getInstance();
    getIt.registerLazySingleton<LocalStorageService>(
      () => LocalStorageService(prefs),
    );
  }

  // ── Auth ──────────────────────────────────────────────────────────────────
  if (!getIt.isRegistered<AuthBloc>()) {
    getIt.registerFactory<AuthBloc>(
      () => AuthBloc(
        getIt<AuthRepository>(),
        getIt<LoginUseCase>(),
        getIt<RegisterUseCase>(),
        getIt<LogoutUseCase>(),
      ),
    );
  }

  if (!getIt.isRegistered<OtpBloc>()) {
    getIt.registerFactory<OtpBloc>(
      () => OtpBloc(getIt<AuthRepository>()),
    );
  }

  // ── User Repository ───────────────────────────────────────────────────────
  if (!getIt.isRegistered<UserRepository>()) {
    getIt.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(dio: getIt(instanceName: 'dio')),
    );
  }

  // ── Splash ────────────────────────────────────────────────────────────────
  if (!getIt.isRegistered<SplashBloc>()) {
    getIt.registerFactory<SplashBloc>(
      () => SplashBloc(
        authRepository: getIt<AuthRepository>(),
        storageService: getIt<LocalStorageService>(),
      ),
    );
  }

  // ── Onboarding ────────────────────────────────────────────────────────────
  if (!getIt.isRegistered<OnboardingCubit>()) {
    getIt.registerFactory<OnboardingCubit>(
      () => OnboardingCubit(storageService: getIt<LocalStorageService>()),
    );
  }

  // ── Expense layer ─────────────────────────────────────────────────────────
  if (!getIt.isRegistered<ExpenseLocalDataSource>()) {
    getIt.registerLazySingleton<ExpenseLocalDataSource>(
      () => ExpenseLocalDataSourceImpl(database: getIt()),
    );
  }
  if (!getIt.isRegistered<ExpenseRemoteDataSource>()) {
    getIt.registerLazySingleton<ExpenseRemoteDataSource>(
      () => ExpenseRemoteDataSourceImpl(dio: getIt()),
    );
  }
  if (!getIt.isRegistered<ExpenseRepository>()) {
    getIt.registerLazySingleton<ExpenseRepository>(
      () => ExpenseRepositoryImpl(
        localDataSource: getIt<ExpenseLocalDataSource>(),
        remoteDataSource: getIt<ExpenseRemoteDataSource>(),
        connectivityService: getIt<ConnectivityService>(),
      ),
    );
  }
  if (!getIt.isRegistered<GetExpensesUseCase>()) {
    getIt.registerLazySingleton(
      () => GetExpensesUseCase(getIt<ExpenseRepository>()),
    );
  }
  if (!getIt.isRegistered<GetExpenseByIdUseCase>()) {
    getIt.registerLazySingleton(
      () => GetExpenseByIdUseCase(getIt<ExpenseRepository>()),
    );
  }
  if (!getIt.isRegistered<SearchExpensesUseCase>()) {
    getIt.registerLazySingleton(
      () => SearchExpensesUseCase(getIt<ExpenseRepository>()),
    );
  }
  if (!getIt.isRegistered<CreateExpenseUseCase>()) {
    getIt.registerLazySingleton(
      () => CreateExpenseUseCase(getIt<ExpenseRepository>()),
    );
  }
  if (!getIt.isRegistered<UpdateExpenseUseCase>()) {
    getIt.registerLazySingleton(
      () => UpdateExpenseUseCase(getIt<ExpenseRepository>()),
    );
  }
  if (!getIt.isRegistered<DeleteExpenseUseCase>()) {
    getIt.registerLazySingleton(
      () => DeleteExpenseUseCase(getIt<ExpenseRepository>()),
    );
  }
  if (!getIt.isRegistered<ExpenseBloc>()) {
    getIt.registerFactory(
      () => ExpenseBloc(
        getExpensesUseCase: getIt<GetExpensesUseCase>(),
        searchExpensesUseCase: getIt<SearchExpensesUseCase>(),
        deleteExpenseUseCase: getIt<DeleteExpenseUseCase>(),
      ),
    );
  }
  if (!getIt.isRegistered<ExpenseDetailsBloc>()) {
    getIt.registerFactory(
      () => ExpenseDetailsBloc(
        getExpenseByIdUseCase: getIt<GetExpenseByIdUseCase>(),
        deleteExpenseUseCase: getIt<DeleteExpenseUseCase>(),
      ),
    );
  }
  if (!getIt.isRegistered<ExpenseFormBloc>()) {
    getIt.registerFactory(
      () => ExpenseFormBloc(
        createExpenseUseCase: getIt<CreateExpenseUseCase>(),
        updateExpenseUseCase: getIt<UpdateExpenseUseCase>(),
      ),
    );
  }

  // ── Category layer ────────────────────────────────────────────────────────
  if (!getIt.isRegistered<CategoryLocalDataSource>()) {
    getIt.registerLazySingleton<CategoryLocalDataSource>(
      () => CategoryLocalDataSourceImpl(database: getIt()),
    );
  }
  if (!getIt.isRegistered<CategoryRemoteDataSource>()) {
    getIt.registerLazySingleton<CategoryRemoteDataSource>(
      () => CategoryRemoteDataSourceImpl(),
    );
  }
  if (!getIt.isRegistered<CategoryRepository>()) {
    getIt.registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(
        localDataSource: getIt<CategoryLocalDataSource>(),
        remoteDataSource: getIt<CategoryRemoteDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<GetCategoriesUseCase>()) {
    getIt.registerLazySingleton(
      () => GetCategoriesUseCase(getIt<CategoryRepository>()),
    );
  }
  if (!getIt.isRegistered<AddCategoryUseCase>()) {
    getIt.registerLazySingleton(
      () => AddCategoryUseCase(getIt<CategoryRepository>()),
    );
  }
  if (!getIt.isRegistered<UpdateCategoryUseCase>()) {
    getIt.registerLazySingleton(
      () => UpdateCategoryUseCase(getIt<CategoryRepository>()),
    );
  }
  if (!getIt.isRegistered<DeleteCategoryUseCase>()) {
    getIt.registerLazySingleton(
      () => DeleteCategoryUseCase(getIt<CategoryRepository>()),
    );
  }
  if (!getIt.isRegistered<CategoryBloc>()) {
    getIt.registerFactory(
      () => CategoryBloc(
        getCategoriesUseCase: getIt<GetCategoriesUseCase>(),
        addCategoryUseCase: getIt<AddCategoryUseCase>(),
        updateCategoryUseCase: getIt<UpdateCategoryUseCase>(),
        deleteCategoryUseCase: getIt<DeleteCategoryUseCase>(),
      ),
    );
  }

  // ── Dashboard ─────────────────────────────────────────────────────────────
  if (!getIt.isRegistered<DashboardBloc>()) {
    getIt.registerFactory(
      () => DashboardBloc(
        expenseRepository: getIt<ExpenseRepository>(),
        connectivityService: getIt<ConnectivityService>(),
      ),
    );
  }

  // ── Receipt Scanner ───────────────────────────────────────────────────────
  if (!getIt.isRegistered<ReceiptScannerBloc>()) {
    getIt.registerFactory(() => ReceiptScannerBloc());
  }
  if (!getIt.isRegistered<ReceiptProcessingBloc>()) {
    getIt.registerFactory(() => ReceiptProcessingBloc(getIt()));
  }

  // ── Analytics ─────────────────────────────────────────────────────────────
  if (!getIt.isRegistered<AnalyticsBloc>()) {
    getIt.registerFactory(
      () => AnalyticsBloc(
        expenseRepository: getIt<ExpenseRepository>(),
        connectivityService: getIt<ConnectivityService>(),
        dio: getIt(instanceName: 'dio'),
      ),
    );
  }

  // ── Reports ───────────────────────────────────────────────────────────────
  if (!getIt.isRegistered<ReportsBloc>()) {
    getIt.registerFactory(
      () => ReportsBloc(expenseRepository: getIt<ExpenseRepository>()),
    );
  }

  // ── Subscription ──────────────────────────────────────────────────────────
  if (!getIt.isRegistered<SubscriptionBloc>()) {
    getIt.registerFactory(
      () => SubscriptionBloc(storage: getIt<LocalStorageService>()),
    );
  }

  // ── Profile ───────────────────────────────────────────────────────────────
  if (!getIt.isRegistered<ProfileBloc>()) {
    getIt.registerFactory(
      () => ProfileBloc(authRepository: getIt<AuthRepository>()),
    );
  }

  // ── Settings ──────────────────────────────────────────────────────────────
  if (!getIt.isRegistered<SettingsBloc>()) {
    getIt.registerFactory(
      () => SettingsBloc(storage: getIt<LocalStorageService>()),
    );
  }

  // ── Sync ──────────────────────────────────────────────────────────────────
  if (!getIt.isRegistered<SyncBloc>()) {
    getIt.registerFactory(
      () => SyncBloc(expenseRepository: getIt<ExpenseRepository>()),
    );
  }

  // ── Ads ───────────────────────────────────────────────────────────────────
  if (!getIt.isRegistered<AdsBloc>()) {
    getIt.registerFactory(
      () => AdsBloc(storage: getIt<LocalStorageService>()),
    );
  }
}
