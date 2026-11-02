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
import '../config/app_config.dart';

const _refreshDioName = 'refreshDio';

void registerCoreDependencies(GetIt sl) {
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
}
