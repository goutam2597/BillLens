import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
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
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
Future<void> configureDependencies() async {
  await getIt.init();

  // Manually register AuthBloc while BLoC registration is not yet generated.
  // Run `flutter pub run build_runner build --delete-conflicting-outputs`
  // to regenerate injection.config.dart and remove this fallback.
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

  // Expense layer fallback registrations.
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
      ),
    );
  }
  if (!getIt.isRegistered<GetExpensesUseCase>()) {
    getIt.registerLazySingleton<GetExpensesUseCase>(
      () => GetExpensesUseCase(getIt<ExpenseRepository>()),
    );
  }
  if (!getIt.isRegistered<GetExpenseByIdUseCase>()) {
    getIt.registerLazySingleton<GetExpenseByIdUseCase>(
      () => GetExpenseByIdUseCase(getIt<ExpenseRepository>()),
    );
  }
  if (!getIt.isRegistered<SearchExpensesUseCase>()) {
    getIt.registerLazySingleton<SearchExpensesUseCase>(
      () => SearchExpensesUseCase(getIt<ExpenseRepository>()),
    );
  }
  if (!getIt.isRegistered<CreateExpenseUseCase>()) {
    getIt.registerLazySingleton<CreateExpenseUseCase>(
      () => CreateExpenseUseCase(getIt<ExpenseRepository>()),
    );
  }
  if (!getIt.isRegistered<UpdateExpenseUseCase>()) {
    getIt.registerLazySingleton<UpdateExpenseUseCase>(
      () => UpdateExpenseUseCase(getIt<ExpenseRepository>()),
    );
  }
  if (!getIt.isRegistered<DeleteExpenseUseCase>()) {
    getIt.registerLazySingleton<DeleteExpenseUseCase>(
      () => DeleteExpenseUseCase(getIt<ExpenseRepository>()),
    );
  }
  if (!getIt.isRegistered<ExpenseBloc>()) {
    getIt.registerFactory<ExpenseBloc>(
      () => ExpenseBloc(
        getExpensesUseCase: getIt<GetExpensesUseCase>(),
        searchExpensesUseCase: getIt<SearchExpensesUseCase>(),
        deleteExpenseUseCase: getIt<DeleteExpenseUseCase>(),
      ),
    );
  }
  if (!getIt.isRegistered<ExpenseDetailsBloc>()) {
    getIt.registerFactory<ExpenseDetailsBloc>(
      () => ExpenseDetailsBloc(
        getExpenseByIdUseCase: getIt<GetExpenseByIdUseCase>(),
        deleteExpenseUseCase: getIt<DeleteExpenseUseCase>(),
      ),
    );
  }
  if (!getIt.isRegistered<ExpenseFormBloc>()) {
    getIt.registerFactory<ExpenseFormBloc>(
      () => ExpenseFormBloc(
        createExpenseUseCase: getIt<CreateExpenseUseCase>(),
        updateExpenseUseCase: getIt<UpdateExpenseUseCase>(),
      ),
    );
  }
}
