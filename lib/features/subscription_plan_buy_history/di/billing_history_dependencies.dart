import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/billing_history_remote_data_source.dart';
import '../data/repositories/billing_history_repository_impl.dart';
import '../domain/repositories/billing_history_repository.dart';
import '../domain/usecases/get_payments_usecase.dart';
import '../domain/usecases/get_plan_history_usecase.dart';
import '../presentation/bloc/payments_bloc.dart';
import '../presentation/bloc/plan_history_bloc.dart';

void registerBillingHistoryDependencies(GetIt sl) {
  sl.registerLazySingleton<BillingHistoryRemoteDataSource>(
    () => BillingHistoryRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<BillingHistoryRepository>(
    () => BillingHistoryRepositoryImpl(sl<BillingHistoryRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetPaymentsUseCase>(
    () => GetPaymentsUseCase(sl<BillingHistoryRepository>()),
  );
  sl.registerLazySingleton<GetPlanHistoryUseCase>(
    () => GetPlanHistoryUseCase(sl<BillingHistoryRepository>()),
  );

  // New bloc per screen.
  sl.registerFactory<PaymentsBloc>(
    () => PaymentsBloc(sl<GetPaymentsUseCase>()),
  );
  sl.registerFactory<PlanHistoryBloc>(
    () => PlanHistoryBloc(sl<GetPlanHistoryUseCase>()),
  );
}
