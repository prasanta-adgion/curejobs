import 'package:get_it/get_it.dart';

import '../../../../core/network/api_client.dart';
import '../data/datasources/registration_remote_data_source.dart';
import '../data/repositories/registration_repository_impl.dart';
import '../domain/repositories/registration_repository.dart';
import '../domain/usecases/register_usecase.dart';
import '../presentation/bloc/registration_bloc.dart';

void registerRegistrationDependencies(GetIt sl) {
  sl.registerLazySingleton<RegistrationRemoteDataSource>(
    () => RegistrationRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<RegistrationRepository>(
    () => RegistrationRepositoryImpl(sl<RegistrationRemoteDataSource>()),
  );

  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(sl<RegistrationRepository>()),
  );

  // New bloc per screen.
  sl.registerFactory<RegistrationBloc>(
    () => RegistrationBloc(sl<RegisterUseCase>()),
  );
}
