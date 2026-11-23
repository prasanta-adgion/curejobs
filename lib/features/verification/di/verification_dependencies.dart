import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/verification_remote_data_source.dart';
import '../data/repositories/verification_repository_impl.dart';
import '../domain/repositories/verification_repository.dart';
import '../domain/usecases/get_document_types_usecase.dart';
import '../domain/usecases/get_verification_eligibility_usecase.dart';

void registerVerificationDependencies(GetIt sl) {
  sl.registerLazySingleton<VerificationRemoteDataSource>(
    () => VerificationRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<VerificationRepository>(
    () => VerificationRepositoryImpl(sl<VerificationRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetVerificationEligibilityUseCase>(
    () => GetVerificationEligibilityUseCase(sl<VerificationRepository>()),
  );
  sl.registerLazySingleton<GetDocumentTypesUseCase>(
    () => GetDocumentTypesUseCase(sl<VerificationRepository>()),
  );
}
