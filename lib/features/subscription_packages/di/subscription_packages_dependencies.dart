import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/subscription_packages_remote_data_source.dart';
import '../data/repositories/subscription_packages_repository_impl.dart';
import '../domain/repositories/subscription_packages_repository.dart';
import '../domain/usecases/get_subscription_packages_usecase.dart';
import '../presentation/bloc/subscription_packages_cubit.dart';

void registerSubscriptionPackagesDependencies(GetIt sl) {
  sl.registerLazySingleton<SubscriptionPackagesRemoteDataSource>(
    () => SubscriptionPackagesRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<SubscriptionPackagesRepository>(
    () => SubscriptionPackagesRepositoryImpl(
      sl<SubscriptionPackagesRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<GetSubscriptionPackagesUseCase>(
    () => GetSubscriptionPackagesUseCase(sl<SubscriptionPackagesRepository>()),
  );

  // New cubit per screen.
  sl.registerFactory<SubscriptionPackagesCubit>(
    () => SubscriptionPackagesCubit(sl<GetSubscriptionPackagesUseCase>()),
  );
}
