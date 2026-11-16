import 'package:get_it/get_it.dart';

import '../../../../../core/network/api_client.dart';
import '../data/datasources/resume_remote_data_source.dart';
import '../data/repositories/resume_repository_impl.dart';
import '../domain/repositories/resume_repository.dart';
import '../domain/usecases/get_resume_file_url_usecase.dart';
import '../domain/usecases/delete_resume_usecase.dart';
import '../domain/usecases/get_resumes_usecase.dart';
import '../domain/usecases/set_default_resume_usecase.dart';
import '../presentation/bloc/resume_bloc.dart';
import '../presentation/bloc/resume_viewer_bloc.dart';

void registerResumeDependencies(GetIt sl) {
  sl.registerLazySingleton<ResumeRemoteDataSource>(
    () => ResumeRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<ResumeRepository>(
    () => ResumeRepositoryImpl(sl<ResumeRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetResumesUseCase>(
    () => GetResumesUseCase(sl<ResumeRepository>()),
  );
  sl.registerLazySingleton<GetResumeFileUrlUseCase>(
    () => GetResumeFileUrlUseCase(sl<ResumeRepository>()),
  );

  sl.registerLazySingleton<SetDefaultResumeUseCase>(
    () => SetDefaultResumeUseCase(sl<ResumeRepository>()),
  );

  sl.registerLazySingleton<DeleteResumeUseCase>(
    () => DeleteResumeUseCase(sl<ResumeRepository>()),
  );

  // New bloc per screen.
  sl.registerFactory<ResumeBloc>(
    () => ResumeBloc(
      getResumes: sl<GetResumesUseCase>(),
      getFileUrl: sl<GetResumeFileUrlUseCase>(),
      setDefault: sl<SetDefaultResumeUseCase>(),
      deleteResume: sl<DeleteResumeUseCase>(),
    ),
  );
  sl.registerFactory<ResumeViewerBloc>(
    () => ResumeViewerBloc(getFileUrl: sl<GetResumeFileUrlUseCase>()),
  );
}
