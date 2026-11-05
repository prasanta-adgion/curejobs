import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/category_remote_data_source.dart';
import '../data/repositories/category_repository_impl.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/usecases/get_categories_usecase.dart';
import '../presentation/bloc/categories_bloc.dart';

void registerCategoryDependencies(GetIt sl) {
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl<CategoryRemoteDataSource>()),
  );

  sl.registerLazySingleton<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(sl<CategoryRepository>()),
  );

  // New bloc per screen.
  sl.registerFactory<CategoriesBloc>(
    () => CategoriesBloc(sl<GetCategoriesUseCase>()),
  );
}
