import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/job_remote_data_source.dart';
import '../data/repositories/job_repository_impl.dart';
import '../domain/repositories/job_repository.dart';
import '../domain/entities/job_feed.dart';
import '../domain/usecases/get_jobs_usecase.dart';
import '../presentation/bloc/jobs_bloc.dart';

void registerAllJobsDependencies(GetIt sl) {
  sl.registerLazySingleton<JobRemoteDataSource>(
    () => JobRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<JobRepository>(
    () => JobRepositoryImpl(sl<JobRemoteDataSource>()),
  );

  sl.registerLazySingleton<GetJobsUseCase>(
    () => GetJobsUseCase(sl<JobRepository>()),
  );

  // New bloc per list; pass the feed: sl<JobsBloc>(param1: JobFeed.all).
  // For one employer's jobs, also pass param2: organizationId.
  sl.registerFactoryParam<JobsBloc, JobFeed, String?>(
    (feed, organizationId) => JobsBloc(
      sl<GetJobsUseCase>(),
      feed: feed,
      organizationId: organizationId,
    ),
  );
}
