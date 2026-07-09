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
import '../database/app_database.dart' as _i982;
import '../network/auth_interceptor.dart' as _i908;
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
    gh.singleton<_i982.AppDatabase>(() => _i982.AppDatabase());
    gh.singleton<_i558.FlutterSecureStorage>(() => localModule.secureStorage);
    await gh.singletonAsync<_i460.SharedPreferences>(
      () => localModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i852.AuthLocalDataSource>(() =>
        _i852.AuthLocalDataSourceImpl(
            secureStorage: gh<_i558.FlutterSecureStorage>()));
    gh.singleton<_i908.AuthInterceptor>(
        () => _i908.AuthInterceptor(gh<_i558.FlutterSecureStorage>()));
    gh.singleton<_i361.Dio>(
        () => networkModule.dio(gh<_i908.AuthInterceptor>()));
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
        () => _i107.AuthRemoteDataSourceImpl(dio: gh<_i361.Dio>()));
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
    return this;
  }
}

class _$LocalModule extends _i519.LocalModule {}

class _$NetworkModule extends _i200.NetworkModule {}
