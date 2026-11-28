import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/verification_remote_data_source.dart';
import '../data/repositories/verification_repository_impl.dart';
import '../domain/repositories/verification_repository.dart';
import '../domain/usecases/add_verification_document_usecase.dart';
import '../domain/usecases/create_verification_request_usecase.dart';
import '../domain/usecases/delete_verification_document_usecase.dart';
import '../domain/usecases/get_document_types_usecase.dart';
import '../domain/usecases/get_my_verification_usecase.dart';
import '../domain/usecases/get_verification_eligibility_usecase.dart';
import '../domain/usecases/get_verification_request_detail_usecase.dart';
import '../domain/usecases/submit_for_review_usecase.dart';
import '../presentation/bloc/verification_bloc.dart';

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
  sl.registerLazySingleton<GetMyVerificationUseCase>(
    () => GetMyVerificationUseCase(sl<VerificationRepository>()),
  );
  sl.registerLazySingleton<CreateVerificationRequestUseCase>(
    () => CreateVerificationRequestUseCase(sl<VerificationRepository>()),
  );
  sl.registerLazySingleton<GetDocumentTypesUseCase>(
    () => GetDocumentTypesUseCase(sl<VerificationRepository>()),
  );
  sl.registerLazySingleton<AddVerificationDocumentUseCase>(
    () => AddVerificationDocumentUseCase(sl<VerificationRepository>()),
  );
  sl.registerLazySingleton<GetVerificationRequestDetailUseCase>(
    () => GetVerificationRequestDetailUseCase(sl<VerificationRepository>()),
  );
  sl.registerLazySingleton<SubmitForReviewUseCase>(
    () => SubmitForReviewUseCase(sl<VerificationRepository>()),
  );
  sl.registerLazySingleton<DeleteVerificationDocumentUseCase>(
    () => DeleteVerificationDocumentUseCase(sl<VerificationRepository>()),
  );

  // A new bloc per page visit.
  sl.registerFactory<VerificationBloc>(
    () => VerificationBloc(
      getEligibility: sl(),
      getMyVerification: sl(),
      getRequestDetail: sl(),
      getDocumentTypes: sl(),
      createRequest: sl(),
      addDocument: sl(),
      deleteDocument: sl(),
      submitForReview: sl(),
    ),
  );
}
