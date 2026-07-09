import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
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
}
