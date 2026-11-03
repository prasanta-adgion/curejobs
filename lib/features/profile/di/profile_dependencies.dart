import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/candidate_remote_data_source.dart';
import '../data/repositories/candidate_repository_impl.dart';
import '../domain/repositories/candidate_repository.dart';
import '../domain/usecases/get_candidate_profile_usecase.dart';
import '../../auth/login/domain/usecases/logout_usecase.dart';
import '../presentation/bloc/candidate_profile_bloc.dart';
import '../presentation/bloc/logout_bloc.dart';

void registerProfileDependencies(GetIt sl) {
  sl.registerLazySingleton<CandidateRemoteDataSource>(
    () => CandidateRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<CandidateRepository>(
    () => CandidateRepositoryImpl(sl<CandidateRemoteDataSource>()),
  );

  sl.registerLazySingleton<GetCandidateProfileUseCase>(
    () => GetCandidateProfileUseCase(sl<CandidateRepository>()),
  );

  // New bloc per screen.
  sl.registerFactory<CandidateProfileBloc>(
    () => CandidateProfileBloc(sl<GetCandidateProfileUseCase>()),
  );

  // LogoutUseCase is registered by the auth feature.
  sl.registerFactory<LogoutBloc>(() => LogoutBloc(sl<LogoutUseCase>()));
}
