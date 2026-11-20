import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';
import '../../category/domain/usecases/get_categories_usecase.dart';
import '../../specialization/domain/usecases/get_specializations_usecase.dart';
import '../data/datasources/job_alerts_remote_data_source.dart';
import '../data/repositories/job_alerts_repository_impl.dart';
import '../domain/repositories/job_alerts_repository.dart';
import '../domain/usecases/get_job_alert_preferences_usecase.dart';
import '../domain/usecases/save_job_alert_preferences_usecase.dart';
import '../presentation/bloc/job_alerts_bloc.dart';

/// Needs the category and specialization use cases registered too.
void registerJobAlertsDependencies(GetIt sl) {
  sl.registerLazySingleton<JobAlertsRemoteDataSource>(
    () => JobAlertsRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<JobAlertsRepository>(
    () => JobAlertsRepositoryImpl(sl<JobAlertsRemoteDataSource>()),
  );

  sl.registerLazySingleton<GetJobAlertPreferencesUseCase>(
    () => GetJobAlertPreferencesUseCase(sl<JobAlertsRepository>()),
  );

  sl.registerLazySingleton<SaveJobAlertPreferencesUseCase>(
    () => SaveJobAlertPreferencesUseCase(sl<JobAlertsRepository>()),
  );

  // New bloc per screen.
  sl.registerFactory<JobAlertsBloc>(
    () => JobAlertsBloc(
      sl<GetJobAlertPreferencesUseCase>(),
      sl<SaveJobAlertPreferencesUseCase>(),
      sl<GetCategoriesUseCase>(),
      sl<GetSpecializationsUseCase>(),
    ),
  );
}
