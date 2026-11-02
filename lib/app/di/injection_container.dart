import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_client.dart';
import '../../core/network/dio_api_client.dart';
import '../../core/network/dio_factory.dart';
import '../../core/network/session_manager.dart';
import '../../core/storage/session_storage.dart';
import '../../core/storage/theme_preference_storage.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../config/app_config.dart';

final sl = GetIt.instance;

const _refreshDioName = 'refreshDio';

void configureDependencies() {
  // Storage
  sl.registerLazySingleton<SharedPreferencesAsync>(SharedPreferencesAsync.new);

  sl.registerLazySingleton<ThemePreferenceStorage>(
    () => LocalThemePreferenceStorage(sl<SharedPreferencesAsync>()),
  );

  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  sl.registerLazySingleton<SessionStorageInterface>(
    () => SecureSessionStorageImpl(sl<FlutterSecureStorage>()),
  );

  // Network
  sl.registerLazySingleton<Dio>(
    () => DioFactory.createRefreshDio(
      baseUrl: AppConfig.baseUrl,
      enableLogging: AppConfig.enableLogging,
      logBodies: AppConfig.current.isDevelopment,
    ),
    instanceName: _refreshDioName,
  );

  sl.registerLazySingleton<SessionManager>(
    () => SessionManager(
      storage: sl<SessionStorageInterface>(),
      refreshDio: sl<Dio>(instanceName: _refreshDioName),
    ),
    dispose: (manager) => manager.dispose(),
  );

  sl.registerLazySingleton<Dio>(
    () => DioFactory.createApiDio(
      baseUrl: AppConfig.baseUrl,
      enableLogging: AppConfig.enableLogging,
      logBodies: AppConfig.current.isDevelopment,
      sessionManager: sl<SessionManager>(),
    ),
  );

  sl.registerLazySingleton<ApiClient>(() => DioApiClient(sl<Dio>()));

  _registerAuth();
}

void _registerAuth() {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );

  // New cubit per screen.
  sl.registerFactory<LoginCubit>(() => LoginCubit(sl<LoginUseCase>()));
}
