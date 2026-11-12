import 'package:get_it/get_it.dart';

import '../../../../../core/network/api_client.dart';
import '../data/datasources/skill_remote_data_source.dart';
import '../data/repositories/skill_repository_impl.dart';
import '../domain/repositories/skill_repository.dart';
import '../domain/usecases/add_skill_usecase.dart';
import '../domain/usecases/delete_skill_usecase.dart';
import '../domain/usecases/get_skills_usecase.dart';
import '../domain/usecases/update_skills_usecase.dart';
import '../presentation/bloc/skills_bloc.dart';

void registerSkillDependencies(GetIt sl) {
  sl.registerLazySingleton<SkillRemoteDataSource>(
    () => SkillRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<SkillRepository>(
    () => SkillRepositoryImpl(sl<SkillRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetSkillsUseCase>(
    () => GetSkillsUseCase(sl<SkillRepository>()),
  );
  sl.registerLazySingleton<UpdateSkillsUseCase>(
    () => UpdateSkillsUseCase(sl<SkillRepository>()),
  );
  sl.registerLazySingleton<AddSkillUseCase>(
    () => AddSkillUseCase(sl<SkillRepository>()),
  );
  sl.registerLazySingleton<DeleteSkillUseCase>(
    () => DeleteSkillUseCase(sl<SkillRepository>()),
  );

  // New bloc per screen.
  sl.registerFactory<SkillsBloc>(
    () => SkillsBloc(
      getSkills: sl<GetSkillsUseCase>(),
      updateSkills: sl<UpdateSkillsUseCase>(),
      addSkill: sl<AddSkillUseCase>(),
      deleteSkill: sl<DeleteSkillUseCase>(),
    ),
  );
}
