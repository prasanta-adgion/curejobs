import 'package:get_it/get_it.dart';

import '../../../../../core/network/api_client.dart';
import '../data/datasources/certification_remote_data_source.dart';
import '../data/repositories/certification_repository_impl.dart';
import '../domain/repositories/certification_repository.dart';
import '../domain/usecases/delete_certification_usecase.dart';
import '../domain/usecases/get_certifications_usecase.dart';
import '../domain/usecases/save_certification_usecase.dart';
import '../presentation/bloc/certification_form_bloc.dart';
import '../presentation/bloc/certifications_bloc.dart';

void registerCertificationDependencies(GetIt sl) {
  sl.registerLazySingleton<CertificationRemoteDataSource>(
    () => CertificationRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<CertificationRepository>(
    () => CertificationRepositoryImpl(sl<CertificationRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetCertificationsUseCase>(
    () => GetCertificationsUseCase(sl<CertificationRepository>()),
  );
  sl.registerLazySingleton<SaveCertificationUseCase>(
    () => SaveCertificationUseCase(sl<CertificationRepository>()),
  );
  sl.registerLazySingleton<DeleteCertificationUseCase>(
    () => DeleteCertificationUseCase(sl<CertificationRepository>()),
  );

  // New blocs per screen.
  sl.registerFactory<CertificationsBloc>(
    () => CertificationsBloc(
      getCertifications: sl<GetCertificationsUseCase>(),
      deleteCertification: sl<DeleteCertificationUseCase>(),
    ),
  );
  sl.registerFactory<CertificationFormBloc>(
    () => CertificationFormBloc(
      sl<SaveCertificationUseCase>(),
      sl<DeleteCertificationUseCase>(),
    ),
  );
}
