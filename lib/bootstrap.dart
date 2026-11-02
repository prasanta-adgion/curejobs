import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'app/config/app_config.dart';
import 'app/config/environment.dart';
import 'app/config/flavor_config.dart';
import 'app/di/injection_container.dart';
import 'app/theme/theme_cubit.dart';
import 'core/error/error_reporter.dart';
import 'core/storage/theme_preference_storage.dart';

/// Initializes configuration, dependencies and global error handling,
/// then runs the app.
Future<void> bootstrap(Environment environment) async {
  // Binding and runApp must live in the same zone.
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      _installErrorHandlers();

      AppConfig.initialize(FlavorConfig.fromEnvironment(environment));
      configureDependencies();

      final storage = sl<ThemePreferenceStorage>();
      final initialMode = await _loadThemeMode(storage);

      runApp(
        BlocProvider(
          create: (_) => ThemeCubit(storage: storage, initialMode: initialMode),
          child: const CureJobsApp(),
        ),
      );
    },
    (error, stackTrace) =>
        ErrorReporter.report(error, stackTrace, fatal: true, reason: 'Zone'),
  );
}

void _installErrorHandlers() {
  // Errors thrown during build / layout / paint.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    ErrorReporter.report(
      details.exception,
      details.stack,
      fatal: !kDebugMode,
      reason: 'Flutter framework',
    );
  };

  // Uncaught async errors from the platform dispatcher.
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    ErrorReporter.report(error, stackTrace, fatal: true, reason: 'Platform');
    return true;
  };
}

Future<ThemeMode> _loadThemeMode(ThemePreferenceStorage storage) async {
  try {
    return await storage.getThemeMode();
  } catch (error, stackTrace) {
    ErrorReporter.report(error, stackTrace, reason: 'Theme preference');
    return ThemeMode.system;
  }
}
