import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../../create_account/domain/usecases/get_location_suggestions_usecase.dart';
import '../data/datasources/job_search_remote_data_source.dart';
import '../data/datasources/job_suggestion_remote_data_source.dart';
import '../data/repositories/job_search_repository_impl.dart';
import '../domain/repositories/job_search_repository.dart';
import '../domain/usecases/search_jobs_usecase.dart';
import '../presentation/bloc/job_search_results_bloc.dart';
import '../data/repositories/job_suggestion_repository_impl.dart';
import '../data/search_history_storage.dart';
import '../domain/repositories/job_suggestion_repository.dart';
import '../domain/usecases/get_job_suggestions_usecase.dart';
import '../presentation/bloc/job_suggestions_bloc.dart';
import '../presentation/bloc/search_location_suggestions_bloc.dart';
import '../presentation/cubit/search_history_cubit.dart';

void registerSearchJobDependencies(GetIt sl) {
  // Local search history (keywords only).
  sl.registerLazySingleton<SearchHistoryStorage>(
    () => LocalSearchHistoryStorage(sl<SharedPreferencesAsync>()),
  );

  // One shared cubit so the dashboard and search screens show the same list.
  sl.registerLazySingleton<SearchHistoryCubit>(
    () => SearchHistoryCubit(sl<SearchHistoryStorage>())..load(),
  );

  // Keyword suggestions.
  sl.registerLazySingleton<JobSuggestionRemoteDataSource>(
    () => JobSuggestionRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Singleton so its in-memory cache lasts for the app session.
  sl.registerLazySingleton<JobSuggestionRepository>(
    () => JobSuggestionRepositoryImpl(sl<JobSuggestionRemoteDataSource>()),
  );

  sl.registerLazySingleton<GetJobSuggestionsUseCase>(
    () => GetJobSuggestionsUseCase(sl<JobSuggestionRepository>()),
  );

  // New bloc per search screen.
  sl.registerFactory<JobSuggestionsBloc>(
    () => JobSuggestionsBloc(sl<GetJobSuggestionsUseCase>()),
  );

  // Job search (results screen).
  sl.registerLazySingleton<JobSearchRemoteDataSource>(
    () => JobSearchRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<JobSearchRepository>(
    () => JobSearchRepositoryImpl(sl<JobSearchRemoteDataSource>()),
  );
  sl.registerLazySingleton<SearchJobsUseCase>(
    () => SearchJobsUseCase(sl<JobSearchRepository>()),
  );
  sl.registerFactory<JobSearchResultsBloc>(
    () => JobSearchResultsBloc(sl<SearchJobsUseCase>()),
  );

  // Location suggestions (AREA, CITY and STATE per query). Reuses the
  // location use case registered by the create_account feature.
  sl.registerFactory<SearchLocationSuggestionsBloc>(
    () => SearchLocationSuggestionsBloc(sl<GetLocationSuggestionsUseCase>()),
  );
}
