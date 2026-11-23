import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';
import '../../subscription_packages/domain/usecases/get_current_plan_usecase.dart';
import '../data/datasources/profile_visibility_remote_data_source.dart';
import '../data/repositories/profile_visibility_repository_impl.dart';
import '../domain/repositories/profile_visibility_repository.dart';
import '../domain/usecases/profile_visibility_usecases.dart';
import '../presentation/bloc/profile_visibility_bloc.dart';

/// Relies on `registerSubscriptionPackagesDependencies` for
/// [GetCurrentPlanUseCase].
void registerProfileVisibilityDependencies(GetIt sl) {
  sl.registerLazySingleton<ProfileVisibilityRemoteDataSource>(
    () => ProfileVisibilityRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<ProfileVisibilityRepository>(
    () => ProfileVisibilityRepositoryImpl(
      sl<ProfileVisibilityRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<GetMatchPrivacyUseCase>(
    () => GetMatchPrivacyUseCase(sl<ProfileVisibilityRepository>()),
  );
  sl.registerLazySingleton<UpdateMatchPrivacyUseCase>(
    () => UpdateMatchPrivacyUseCase(sl<ProfileVisibilityRepository>()),
  );
  sl.registerLazySingleton<GetProfileActivityUseCase>(
    () => GetProfileActivityUseCase(sl<ProfileVisibilityRepository>()),
  );

  // New bloc per screen.
  sl.registerFactory<ProfileVisibilityBloc>(
    () => ProfileVisibilityBloc(
      getCurrentPlan: sl<GetCurrentPlanUseCase>(),
      getMatchPrivacy: sl<GetMatchPrivacyUseCase>(),
      updateMatchPrivacy: sl<UpdateMatchPrivacyUseCase>(),
      getProfileActivity: sl<GetProfileActivityUseCase>(),
    ),
  );
}
