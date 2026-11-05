import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/specialization_remote_data_source.dart';
import '../data/repositories/specialization_repository_impl.dart';
import '../domain/repositories/specialization_repository.dart';
import '../domain/usecases/get_specializations_usecase.dart';
import '../presentation/bloc/specializations_bloc.dart';

void registerSpecializationDependencies(GetIt sl) {
  sl.registerLazySingleton<SpecializationRemoteDataSource>(
    () => SpecializationRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<SpecializationRepository>(
    () => SpecializationRepositoryImpl(sl<SpecializationRemoteDataSource>()),
  );

  sl.registerLazySingleton<GetSpecializationsUseCase>(
    () => GetSpecializationsUseCase(sl<SpecializationRepository>()),
  );

  // New bloc per screen.
  sl.registerFactory<SpecializationsBloc>(
    () => SpecializationsBloc(sl<GetSpecializationsUseCase>()),
  );
}
