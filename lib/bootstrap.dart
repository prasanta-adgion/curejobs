import 'package:curejobs/app/config/environment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'app/config/app_config.dart';
import 'app/config/flavor_config.dart';
import 'app/di/injection.dart';
import 'app/theme/theme_cubit.dart';
import 'core/storage/theme_preference_storage.dart';

Future<void> bootstrap(Environment environment) async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.initialize(FlavorConfig.fromEnvironment(environment));
  configureDependencies();

  final storage = sl<ThemePreferenceStorage>();

  ThemeMode initialMode;

  try {
    initialMode = await storage.getThemeMode();
  } catch (_) {
    initialMode = ThemeMode.system;
  }

  runApp(
    BlocProvider(
      create: (_) => ThemeCubit(storage: storage, initialMode: initialMode),
      child: const CureJobsApp(),
    ),
  );
}

// 	Initialize dependencies, storage, configuration, and application services
