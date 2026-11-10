import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/create_account_remote_data_source.dart';
import '../data/datasources/location_remote_data_source.dart';
import '../data/repositories/create_account_repository_impl.dart';
import '../data/repositories/location_repository_impl.dart';
import '../domain/enums/location_type.dart';
import '../domain/repositories/create_account_repository.dart';
import '../domain/repositories/location_repository.dart';
import '../domain/usecases/create_account_usecase.dart';
import '../domain/usecases/get_location_suggestions_usecase.dart';
import '../presentation/bloc/create_account_bloc.dart';
import '../presentation/bloc/location_suggestions_bloc.dart';

void registerCreateAccountDependencies(GetIt sl) {
  // Location suggestions
  sl.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(sl<LocationRemoteDataSource>()),
  );

  sl.registerLazySingleton<GetLocationSuggestionsUseCase>(
    () => GetLocationSuggestionsUseCase(sl<LocationRepository>()),
  );

  // One bloc per location field; param1 is the field's type.
  sl.registerFactoryParam<LocationSuggestionsBloc, LocationType, void>(
    (type, _) => LocationSuggestionsBloc(
      sl<GetLocationSuggestionsUseCase>(),
      type: type,
    ),
  );

  // Account creation
  sl.registerLazySingleton<CreateAccountRemoteDataSource>(
    () => CreateAccountRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<CreateAccountRepository>(
    () => CreateAccountRepositoryImpl(sl<CreateAccountRemoteDataSource>()),
  );

  sl.registerLazySingleton<CreateAccountUseCase>(
    () => CreateAccountUseCase(sl<CreateAccountRepository>()),
  );

  // New bloc per screen.
  sl.registerFactory<CreateAccountBloc>(
    () => CreateAccountBloc(sl<CreateAccountUseCase>()),
  );
}
