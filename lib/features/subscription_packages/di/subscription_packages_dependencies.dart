import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/subscription_packages_remote_data_source.dart';
import '../data/repositories/subscription_packages_repository_impl.dart';
import '../domain/repositories/subscription_packages_repository.dart';
import '../domain/usecases/get_current_plan_usecase.dart';
import '../domain/usecases/get_subscription_packages_usecase.dart';
import '../domain/usecases/start_plan_purchase_usecase.dart';
import '../presentation/bloc/current_plan_bloc.dart';
import '../presentation/bloc/plan_purchase_bloc.dart';
import '../presentation/bloc/subscription_packages_bloc.dart';

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

  sl.registerLazySingleton<GetCurrentPlanUseCase>(
    () => GetCurrentPlanUseCase(sl<SubscriptionPackagesRepository>()),
  );

  sl.registerLazySingleton<CreatePurchaseUseCase>(
    () => CreatePurchaseUseCase(sl<SubscriptionPackagesRepository>()),
  );
  sl.registerLazySingleton<CreateRazorpaySubscriptionUseCase>(
    () =>
        CreateRazorpaySubscriptionUseCase(sl<SubscriptionPackagesRepository>()),
  );

  sl.registerLazySingleton<VerifyRazorpayPaymentUseCase>(
    () => VerifyRazorpayPaymentUseCase(sl<SubscriptionPackagesRepository>()),
  );

  sl.registerLazySingleton<SelectPlanUseCase>(
    () => SelectPlanUseCase(sl<SubscriptionPackagesRepository>()),
  );

  // New bloc per screen.
  sl.registerFactory<CurrentPlanBloc>(
    () => CurrentPlanBloc(sl<GetCurrentPlanUseCase>()),
  );
  sl.registerFactory<SubscriptionPackagesBloc>(
    () => SubscriptionPackagesBloc(sl<GetSubscriptionPackagesUseCase>()),
  );
  sl.registerFactory<PlanPurchaseBloc>(
    () => PlanPurchaseBloc(
      sl<CreatePurchaseUseCase>(),
      sl<CreateRazorpaySubscriptionUseCase>(),
      sl<VerifyRazorpayPaymentUseCase>(),
      sl<SelectPlanUseCase>(),
      sl<GetCurrentPlanUseCase>(),
    ),
  );
}
