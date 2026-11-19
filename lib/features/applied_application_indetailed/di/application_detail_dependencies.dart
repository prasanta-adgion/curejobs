import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';
import '../../applied_application/domain/usecases/withdraw_application_usecase.dart';
import '../data/datasources/application_detail_remote_data_source.dart';
import '../data/repositories/application_detail_repository_impl.dart';
import '../domain/repositories/application_detail_repository.dart';
import '../domain/usecases/get_application_detail_usecase.dart';
import '../presentation/cubit/application_detail_cubit.dart';

/// Register after `registerApplyApplicationDependencies` (uses its withdraw
/// use case).
void registerApplicationDetailDependencies(GetIt sl) {
  sl.registerLazySingleton<ApplicationDetailRemoteDataSource>(
    () => ApplicationDetailRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<ApplicationDetailRepository>(
    () => ApplicationDetailRepositoryImpl(
      sl<ApplicationDetailRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<GetApplicationDetailUseCase>(
    () => GetApplicationDetailUseCase(sl<ApplicationDetailRepository>()),
  );

  // New cubit per screen.
  sl.registerFactory<ApplicationDetailCubit>(
    () => ApplicationDetailCubit(
      sl<GetApplicationDetailUseCase>(),
      sl<WithdrawApplicationUseCase>(),
    ),
  );
}
