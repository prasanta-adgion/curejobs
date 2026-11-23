import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';
import '../../media_preview/domain/usecases/get_file_access_url_usecase.dart';
import '../data/datasources/organization_remote_data_source.dart';
import '../data/repositories/organization_repository_impl.dart';
import '../domain/repositories/organization_repository.dart';
import '../domain/usecases/get_organization_usecase.dart';
import '../presentation/bloc/organization_details_cubit.dart';

/// The employer's jobs use `JobsBloc` from all_jobs (param2: organizationId).
void registerOrganizationDetailsDependencies(GetIt sl) {
  sl.registerLazySingleton<OrganizationRemoteDataSource>(
    () => OrganizationRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<OrganizationRepository>(
    () => OrganizationRepositoryImpl(sl<OrganizationRemoteDataSource>()),
  );

  sl.registerLazySingleton<GetOrganizationUseCase>(
    () => GetOrganizationUseCase(sl<OrganizationRepository>()),
  );

  // New cubit per screen.
  sl.registerFactory<OrganizationDetailsCubit>(
    () => OrganizationDetailsCubit(
      sl<GetOrganizationUseCase>(),
      sl<GetFileAccessUrlUseCase>(),
    ),
  );
}
