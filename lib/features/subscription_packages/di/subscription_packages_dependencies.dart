import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/subscription_packages_remote_data_source.dart';
import '../data/repositories/subscription_packages_repository_impl.dart';
import '../domain/repositories/subscription_packages_repository.dart';
import '../domain/usecases/get_current_plan_usecase.dart';
import '../domain/usecases/get_subscription_packages_usecase.dart';
import '../domain/usecases/cancel_auto_renew_usecase.dart';
import '../domain/usecases/create_purchase_usecase.dart';
import '../domain/usecases/create_razorpay_subscription_usecase.dart';
import '../domain/usecases/get_package_requests_usecase.dart';
import '../domain/usecases/request_package_usecase.dart';
import '../domain/usecases/select_plan_usecase.dart';
import '../presentation/bloc/package_request_cubit.dart';
import '../domain/usecases/verify_razorpay_payment_usecase.dart';
import '../presentation/bloc/cancel_auto_pay_cubit.dart';
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

  sl.registerLazySingleton<CancelAutoRenewUseCase>(
    () => CancelAutoRenewUseCase(sl<SubscriptionPackagesRepository>()),
  );

  sl.registerLazySingleton<GetPackageRequestsUseCase>(
    () => GetPackageRequestsUseCase(sl<SubscriptionPackagesRepository>()),
  );
  sl.registerLazySingleton<RequestPackageUseCase>(
    () => RequestPackageUseCase(sl<SubscriptionPackagesRepository>()),
  );

  // New bloc per screen.
  sl.registerFactory<PackageRequestCubit>(
    () => PackageRequestCubit(
      sl<RequestPackageUseCase>(),
      sl<GetPackageRequestsUseCase>(),
    ),
  );
  sl.registerFactory<CancelAutoPayCubit>(
    () => CancelAutoPayCubit(sl<CancelAutoRenewUseCase>()),
  );
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
