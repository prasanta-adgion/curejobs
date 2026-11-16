import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/apply_job_remote_data_source.dart';
import '../data/repositories/apply_job_repository_impl.dart';
import '../domain/repositories/apply_job_repository.dart';
import '../domain/usecases/get_application_eligibility_usecase.dart';
import '../presentation/bloc/eligibility_cubit.dart';

void registerApplyJobDependencies(GetIt sl) {
  sl.registerLazySingleton<ApplyJobRemoteDataSource>(
    () => ApplyJobRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<ApplyJobRepository>(
    () => ApplyJobRepositoryImpl(sl<ApplyJobRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetApplicationEligibilityUseCase>(
    () => GetApplicationEligibilityUseCase(sl<ApplyJobRepository>()),
  );

  // New cubit per screen.
  sl.registerFactory<EligibilityCubit>(
    () => EligibilityCubit(sl<GetApplicationEligibilityUseCase>()),
  );
}
