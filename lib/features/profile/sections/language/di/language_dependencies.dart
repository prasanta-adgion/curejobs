import 'package:get_it/get_it.dart';

import '../../../../../core/network/api_client.dart';
import '../data/datasources/language_remote_data_source.dart';
import '../data/repositories/language_repository_impl.dart';
import '../domain/repositories/language_repository.dart';
import '../domain/usecases/add_language_usecase.dart';
import '../domain/usecases/delete_language_usecase.dart';
import '../domain/usecases/get_languages_usecase.dart';
import '../domain/usecases/update_language_usecase.dart';
import '../presentation/bloc/languages_bloc.dart';

void registerLanguageDependencies(GetIt sl) {
  sl.registerLazySingleton<LanguageRemoteDataSource>(
    () => LanguageRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<LanguageRepository>(
    () => LanguageRepositoryImpl(sl<LanguageRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetLanguagesUseCase>(
    () => GetLanguagesUseCase(sl<LanguageRepository>()),
  );
  sl.registerLazySingleton<AddLanguageUseCase>(
    () => AddLanguageUseCase(sl<LanguageRepository>()),
  );
  sl.registerLazySingleton<UpdateLanguageUseCase>(
    () => UpdateLanguageUseCase(sl<LanguageRepository>()),
  );
  sl.registerLazySingleton<DeleteLanguageUseCase>(
    () => DeleteLanguageUseCase(sl<LanguageRepository>()),
  );

  // New bloc per screen.
  sl.registerFactory<LanguagesBloc>(
    () => LanguagesBloc(
      getLanguages: sl<GetLanguagesUseCase>(),
      addLanguage: sl<AddLanguageUseCase>(),
      updateLanguage: sl<UpdateLanguageUseCase>(),
      deleteLanguage: sl<DeleteLanguageUseCase>(),
    ),
  );
}
