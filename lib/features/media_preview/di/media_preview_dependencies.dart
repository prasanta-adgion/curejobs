import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/dio_factory.dart';
import '../data/datasource/image_upload_remote_datasource.dart';
import '../data/datasource/s3_upload_data_source.dart';
import '../data/repositories/media_upload_repository_impl.dart';
import '../domain/repositories/media_upload_repository.dart';
import '../domain/usecases/upload_media_usecase.dart';
import '../presentation/bloc/media_upload_bloc.dart';

const _s3DioName = 's3Dio';

void registerMediaPreviewDependencies(GetIt sl) {
  sl.registerLazySingleton<Dio>(
    DioFactory.createS3Dio,
    instanceName: _s3DioName,
  );

  sl.registerLazySingleton<ImageUploadRemoteDataSource>(
    () => ImageUploadRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<S3UploadDataSource>(
    () => S3UploadDataSourceImpl(sl<Dio>(instanceName: _s3DioName)),
  );

  sl.registerLazySingleton<MediaUploadRepository>(
    () => MediaUploadRepositoryImpl(
      sl<ImageUploadRemoteDataSource>(),
      sl<S3UploadDataSource>(),
    ),
  );

  sl.registerLazySingleton<UploadMediaUseCase>(
    () => UploadMediaUseCase(sl<MediaUploadRepository>()),
  );

  // New bloc per screen.
  sl.registerFactory<MediaUploadBloc>(
    () => MediaUploadBloc(sl<UploadMediaUseCase>()),
  );
}
