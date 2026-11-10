import 'package:get_it/get_it.dart';

import '../../../../../core/network/api_client.dart';
import '../data/datasources/experience_remote_data_source.dart';
import '../data/repositories/experience_repository_impl.dart';
import '../domain/repositories/experience_repository.dart';
import '../domain/usecases/delete_experience_usecase.dart';
import '../domain/usecases/get_experience_usecase.dart';
import '../domain/usecases/save_experience_usecase.dart';
import '../presentation/bloc/experience_bloc.dart';
import '../presentation/bloc/experience_form_bloc.dart';

void registerExperienceDependencies(GetIt sl) {
  sl.registerLazySingleton<ExperienceRemoteDataSource>(
    () => ExperienceRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<ExperienceRepository>(
    () => ExperienceRepositoryImpl(sl<ExperienceRemoteDataSource>()),
  );

  sl.registerLazySingleton<GetExperienceUseCase>(
    () => GetExperienceUseCase(sl<ExperienceRepository>()),
  );
  sl.registerLazySingleton<SaveExperienceUseCase>(
    () => SaveExperienceUseCase(sl<ExperienceRepository>()),
  );
  sl.registerLazySingleton<DeleteExperienceUseCase>(
    () => DeleteExperienceUseCase(sl<ExperienceRepository>()),
  );

  // New bloc per screen.
  sl.registerFactory<ExperienceBloc>(
    () => ExperienceBloc(
      sl<GetExperienceUseCase>(),
      sl<DeleteExperienceUseCase>(),
    ),
  );
  sl.registerFactory<ExperienceFormBloc>(
    () => ExperienceFormBloc(
      sl<SaveExperienceUseCase>(),
      sl<DeleteExperienceUseCase>(),
    ),
  );
}
