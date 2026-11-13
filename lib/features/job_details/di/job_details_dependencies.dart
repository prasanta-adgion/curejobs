import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/job_details_remote_data_source.dart';
import '../data/repositories/job_details_repository_impl.dart';
import '../domain/repositories/job_details_repository.dart';
import '../domain/usecases/track_job_view_usecase.dart';

void registerJobDetailsDependencies(GetIt sl) {
  sl.registerLazySingleton<JobDetailsRemoteDataSource>(
    () => JobDetailsRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<JobDetailsRepository>(
    () => JobDetailsRepositoryImpl(sl<JobDetailsRemoteDataSource>()),
  );
  sl.registerLazySingleton<TrackJobViewUseCase>(
    () => TrackJobViewUseCase(sl<JobDetailsRepository>()),
  );
}
