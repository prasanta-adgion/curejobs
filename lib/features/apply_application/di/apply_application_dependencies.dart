import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/apply_application_remote_data_source.dart';
import '../data/repositories/apply_application_repository_impl.dart';
import '../domain/repositories/apply_application_repository.dart';
import '../domain/usecases/get_my_applications_usecase.dart';
import '../domain/usecases/withdraw_application_usecase.dart';
import '../presentation/bloc/my_applications_bloc.dart';

void registerApplyApplicationDependencies(GetIt sl) {
  sl.registerLazySingleton<ApplyApplicationRemoteDataSource>(
    () => ApplyApplicationRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<ApplyApplicationRepository>(
    () => ApplyApplicationRepositoryImpl(
      sl<ApplyApplicationRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<GetMyApplicationsUseCase>(
    () => GetMyApplicationsUseCase(sl<ApplyApplicationRepository>()),
  );
  sl.registerLazySingleton<WithdrawApplicationUseCase>(
    () => WithdrawApplicationUseCase(sl<ApplyApplicationRepository>()),
  );

  // New bloc per screen.
  sl.registerFactory<MyApplicationsBloc>(
    () => MyApplicationsBloc(
      sl<GetMyApplicationsUseCase>(),
      sl<WithdrawApplicationUseCase>(),
    ),
  );
}
