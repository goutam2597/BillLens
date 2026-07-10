// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/ads/presentation/bloc/ads_bloc.dart' as _i810;
import '../../features/analytics/presentation/bloc/analytics_bloc.dart' as _i70;
import '../../features/auth/data/datasources/auth_local_data_source.dart'
    as _i852;
import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i48;
import '../../features/auth/domain/usecases/register_usecase.dart' as _i941;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/auth/presentation/bloc/otp_bloc.dart' as _i1048;
import '../../features/categories/data/datasources/category_local_data_source.dart'
    as _i390;
import '../../features/categories/data/datasources/category_remote_data_source.dart'
    as _i162;
import '../../features/categories/data/repositories/category_repository_impl.dart'
    as _i894;
import '../../features/categories/domain/repositories/category_repository.dart'
    as _i266;
import '../../features/categories/domain/usecases/category_usecases.dart'
    as _i772;
import '../../features/categories/presentation/bloc/category_bloc.dart' as _i80;
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart'
    as _i652;
import '../../features/expenses/data/datasources/expense_local_data_source.dart'
    as _i22;
import '../../features/expenses/data/datasources/expense_remote_data_source.dart'
    as _i489;
import '../../features/expenses/data/repositories/expense_repository_impl.dart'
    as _i786;
import '../../features/expenses/domain/repositories/expense_repository.dart'
    as _i939;
import '../../features/expenses/domain/usecases/create_expense_usecase.dart'
    as _i188;
import '../../features/expenses/domain/usecases/delete_expense_usecase.dart'
    as _i172;
import '../../features/expenses/domain/usecases/get_expense_by_id_usecase.dart'
    as _i844;
import '../../features/expenses/domain/usecases/get_expenses_usecase.dart'
    as _i821;
import '../../features/expenses/domain/usecases/search_expenses_usecase.dart'
    as _i39;
import '../../features/expenses/domain/usecases/update_expense_usecase.dart'
    as _i721;
import '../../features/profile/presentation/bloc/profile_bloc.dart' as _i469;
import '../../features/receipt_scanner/presentation/bloc/receipt_processing_bloc.dart'
    as _i473;
import '../../features/receipt_scanner/presentation/bloc/receipt_scanner_bloc.dart'
    as _i1044;
import '../../features/reports/presentation/bloc/reports_bloc.dart' as _i554;
import '../../features/settings/presentation/bloc/settings_bloc.dart' as _i585;
import '../../features/subscription/presentation/bloc/subscription_bloc.dart'
    as _i858;
import '../../features/sync/presentation/bloc/sync_bloc.dart' as _i21;
import '../database/app_database.dart' as _i982;
import '../local/local_storage_service.dart' as _i847;
import '../network/auth_interceptor.dart' as _i908;
import '../network/connectivity_service.dart' as _i491;
import '../network/network_module.dart' as _i200;
import 'local_module.dart' as _i519;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final localModule = _$LocalModule();
    final networkModule = _$NetworkModule();
    gh.factory<_i1044.ReceiptScannerBloc>(() => _i1044.ReceiptScannerBloc());
    gh.singleton<_i982.AppDatabase>(() => _i982.AppDatabase());
    gh.singleton<_i558.FlutterSecureStorage>(() => localModule.secureStorage);
    await gh.singletonAsync<_i460.SharedPreferences>(
      () => localModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i491.ConnectivityService>(
        () => _i491.ConnectivityService());
    gh.lazySingleton<_i162.CategoryRemoteDataSource>(
        () => _i162.CategoryRemoteDataSourceImpl());
    gh.lazySingleton<_i390.CategoryLocalDataSource>(() =>
        _i390.CategoryLocalDataSourceImpl(database: gh<_i982.AppDatabase>()));
    gh.lazySingleton<_i22.ExpenseLocalDataSource>(() =>
        _i22.ExpenseLocalDataSourceImpl(database: gh<_i982.AppDatabase>()));
    gh.lazySingleton<_i852.AuthLocalDataSource>(() =>
        _i852.AuthLocalDataSourceImpl(
            secureStorage: gh<_i558.FlutterSecureStorage>()));
    gh.singleton<_i908.AuthInterceptor>(
        () => _i908.AuthInterceptor(gh<_i558.FlutterSecureStorage>()));
    gh.singleton<_i847.LocalStorageService>(
        () => _i847.LocalStorageService(gh<_i460.SharedPreferences>()));
    gh.factory<_i810.AdsBloc>(
        () => _i810.AdsBloc(storage: gh<_i847.LocalStorageService>()));
    gh.factory<_i585.SettingsBloc>(
        () => _i585.SettingsBloc(storage: gh<_i847.LocalStorageService>()));
    gh.factory<_i858.SubscriptionBloc>(
        () => _i858.SubscriptionBloc(storage: gh<_i847.LocalStorageService>()));
    gh.lazySingleton<_i266.CategoryRepository>(
        () => _i894.CategoryRepositoryImpl(
              localDataSource: gh<_i390.CategoryLocalDataSource>(),
              remoteDataSource: gh<_i162.CategoryRemoteDataSource>(),
            ));
    gh.lazySingleton<_i772.GetCategoriesUseCase>(
        () => _i772.GetCategoriesUseCase(gh<_i266.CategoryRepository>()));
    gh.lazySingleton<_i772.AddCategoryUseCase>(
        () => _i772.AddCategoryUseCase(gh<_i266.CategoryRepository>()));
    gh.lazySingleton<_i772.UpdateCategoryUseCase>(
        () => _i772.UpdateCategoryUseCase(gh<_i266.CategoryRepository>()));
    gh.lazySingleton<_i772.DeleteCategoryUseCase>(
        () => _i772.DeleteCategoryUseCase(gh<_i266.CategoryRepository>()));
    gh.singleton<_i361.Dio>(
      () => networkModule.dio(gh<_i908.AuthInterceptor>()),
      instanceName: 'dio',
    );
    gh.factory<_i80.CategoryBloc>(() => _i80.CategoryBloc(
          getCategoriesUseCase: gh<_i772.GetCategoriesUseCase>(),
          addCategoryUseCase: gh<_i772.AddCategoryUseCase>(),
          updateCategoryUseCase: gh<_i772.UpdateCategoryUseCase>(),
          deleteCategoryUseCase: gh<_i772.DeleteCategoryUseCase>(),
        ));
    gh.lazySingleton<_i489.ExpenseRemoteDataSource>(() =>
        _i489.ExpenseRemoteDataSourceImpl(
            dio: gh<_i361.Dio>(instanceName: 'dio')));
    gh.lazySingleton<_i939.ExpenseRepository>(() => _i786.ExpenseRepositoryImpl(
          localDataSource: gh<_i22.ExpenseLocalDataSource>(),
          remoteDataSource: gh<_i489.ExpenseRemoteDataSource>(),
          connectivityService: gh<_i491.ConnectivityService>(),
        ));
    gh.factory<_i473.ReceiptProcessingBloc>(
        () => _i473.ReceiptProcessingBloc(gh<_i361.Dio>(instanceName: 'dio')));
    gh.lazySingleton<_i188.CreateExpenseUseCase>(
        () => _i188.CreateExpenseUseCase(gh<_i939.ExpenseRepository>()));
    gh.lazySingleton<_i172.DeleteExpenseUseCase>(
        () => _i172.DeleteExpenseUseCase(gh<_i939.ExpenseRepository>()));
    gh.lazySingleton<_i844.GetExpenseByIdUseCase>(
        () => _i844.GetExpenseByIdUseCase(gh<_i939.ExpenseRepository>()));
    gh.lazySingleton<_i821.GetExpensesUseCase>(
        () => _i821.GetExpensesUseCase(gh<_i939.ExpenseRepository>()));
    gh.lazySingleton<_i39.SearchExpensesUseCase>(
        () => _i39.SearchExpensesUseCase(gh<_i939.ExpenseRepository>()));
    gh.lazySingleton<_i721.UpdateExpenseUseCase>(
        () => _i721.UpdateExpenseUseCase(gh<_i939.ExpenseRepository>()));
    gh.lazySingleton<_i107.AuthRemoteDataSource>(() =>
        _i107.AuthRemoteDataSourceImpl(gh<_i361.Dio>(instanceName: 'dio')));
    gh.factory<_i554.ReportsBloc>(() =>
        _i554.ReportsBloc(expenseRepository: gh<_i939.ExpenseRepository>()));
    gh.factory<_i21.SyncBloc>(
        () => _i21.SyncBloc(expenseRepository: gh<_i939.ExpenseRepository>()));
    gh.factory<_i652.DashboardBloc>(() => _i652.DashboardBloc(
          expenseRepository: gh<_i939.ExpenseRepository>(),
          connectivityService: gh<_i491.ConnectivityService>(),
        ));
    gh.factory<_i70.AnalyticsBloc>(() => _i70.AnalyticsBloc(
          expenseRepository: gh<_i939.ExpenseRepository>(),
          connectivityService: gh<_i491.ConnectivityService>(),
          dio: gh<_i361.Dio>(instanceName: 'dio'),
        ));
    gh.lazySingleton<_i787.AuthRepository>(() => _i153.AuthRepositoryImpl(
          remoteDataSource: gh<_i107.AuthRemoteDataSource>(),
          localDataSource: gh<_i852.AuthLocalDataSource>(),
        ));
    gh.lazySingleton<_i188.LoginUseCase>(
        () => _i188.LoginUseCase(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i48.LogoutUseCase>(
        () => _i48.LogoutUseCase(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i941.RegisterUseCase>(
        () => _i941.RegisterUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i469.ProfileBloc>(
        () => _i469.ProfileBloc(authRepository: gh<_i787.AuthRepository>()));
    gh.factory<_i797.AuthBloc>(() => _i797.AuthBloc(
          gh<_i787.AuthRepository>(),
          gh<_i188.LoginUseCase>(),
          gh<_i941.RegisterUseCase>(),
          gh<_i48.LogoutUseCase>(),
        ));
    gh.factory<_i1048.OtpBloc>(
        () => _i1048.OtpBloc(gh<_i787.AuthRepository>()));
    return this;
  }
}

class _$LocalModule extends _i519.LocalModule {}

class _$NetworkModule extends _i200.NetworkModule {}
