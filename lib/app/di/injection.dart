import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/dio_api_client.dart';
import '../../core/network/interceptors/logging_interceptor.dart';
import '../../core/network/interceptors/retry_interceptor.dart';
import '../../core/network/interceptors/session_interceptor.dart';
import '../../core/network/session_refresh_service.dart';
import '../../core/storage/session_storage.dart';
import '../../core/storage/theme_preference_storage.dart';

final sl = GetIt.instance;

void configureDependencies() {
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

  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          ApiConstants.contentTypeHeader: ApiConstants.applicationJson,
          ApiConstants.acceptHeader: ApiConstants.applicationJson,
        },
      ),
    );

    final sessionManager = sl<SessionManager>();
    dio.interceptors.add(
      SessionInterceptor(
        dio: dio,
        sessionManager: sessionManager,
        trustedBaseUrl: AppConfig.baseUrl,
      ),
    );
    dio.interceptors.add(RetryInterceptor(dio));
    if (AppConfig.enableLogging) {
      dio.interceptors.add(const LoggingInterceptor());
    }

    return dio;
  });

  sl.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          ApiConstants.contentTypeHeader: ApiConstants.applicationJson,
          ApiConstants.acceptHeader: ApiConstants.applicationJson,
        },
      ),
    ),
    instanceName: 'refreshDio',
  );

  sl.registerLazySingleton<SessionManager>(
    () => SessionManager(
      storage: sl<SessionStorageInterface>(),
      refreshDio: sl<Dio>(instanceName: 'refreshDio'),
    ),
  );

  sl.registerLazySingleton<ApiClient>(() => DioApiClient(sl<Dio>()));
}
