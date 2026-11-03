import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/job_remote_data_source.dart';
import '../data/repositories/job_repository_impl.dart';
import '../domain/repositories/job_repository.dart';
import '../domain/usecases/get_jobs_usecase.dart';
import '../presentation/bloc/jobs_bloc.dart';

void registerDashboardDependencies(GetIt sl) {
  sl.registerLazySingleton<JobRemoteDataSource>(
    () => JobRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<JobRepository>(
    () => JobRepositoryImpl(sl<JobRemoteDataSource>()),
  );

  sl.registerLazySingleton<GetJobsUseCase>(
    () => GetJobsUseCase(sl<JobRepository>()),
  );

  // New bloc per screen.
  sl.registerFactory<JobsBloc>(() => JobsBloc(sl<GetJobsUseCase>()));
}
