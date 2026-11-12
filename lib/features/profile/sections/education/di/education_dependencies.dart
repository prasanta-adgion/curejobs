import 'package:get_it/get_it.dart';

import '../../../../../core/network/api_client.dart';
import '../data/datasources/education_remote_data_source.dart';
import '../data/repositories/education_repository_impl.dart';
import '../domain/repositories/education_repository.dart';
import '../domain/usecases/delete_education_usecase.dart';
import '../domain/usecases/get_education_usecase.dart';
import '../domain/usecases/save_education_usecase.dart';
import '../presentation/bloc/education_bloc.dart';
import '../presentation/bloc/education_form_bloc.dart';

void registerEducationDependencies(GetIt sl) {
  sl.registerLazySingleton<EducationRemoteDataSource>(
    () => EducationRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<EducationRepository>(
    () => EducationRepositoryImpl(sl<EducationRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetEducationUseCase>(
    () => GetEducationUseCase(sl<EducationRepository>()),
  );
  sl.registerLazySingleton<SaveEducationUseCase>(
    () => SaveEducationUseCase(sl<EducationRepository>()),
  );
  sl.registerLazySingleton<DeleteEducationUseCase>(
    () => DeleteEducationUseCase(sl<EducationRepository>()),
  );

  // New blocs per screen.
  sl.registerFactory<EducationBloc>(
    () => EducationBloc(
      getEducation: sl<GetEducationUseCase>(),
      deleteEducation: sl<DeleteEducationUseCase>(),
    ),
  );
  sl.registerFactory<EducationFormBloc>(
    () => EducationFormBloc(
      sl<SaveEducationUseCase>(),
      sl<DeleteEducationUseCase>(),
    ),
  );
}
