import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'theme/app_theme.dart';
import 'theme/theme_cubit.dart';

import '../core/network/network_inspector.dart';
import '../core/widgets/app_snackbar.dart';
import '../features/splash/presentation/pages/splash_page.dart';

class CureJobsApp extends StatefulWidget {
  const CureJobsApp({super.key});

  @override
  State<CureJobsApp> createState() => _CureJobsAppState();
}

class _CureJobsAppState extends State<CureJobsApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    if (NetworkInspector.isEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final navigator = _navigatorKey.currentState;
        if (navigator != null) NetworkInspector.attach(navigator);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          title: 'CureJobs',
          debugShowCheckedModeBanner: false,
          navigatorKey: _navigatorKey,

          // Lets AppSnackbar show messages without a BuildContext
          scaffoldMessengerKey: AppSnackbar.messengerKey,

          // Global theme configuration
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,

          // Initial screen
          home: const SplashPage(),
        );
      },
    );
  }
}

// Configure MaterialApp, themes, navigation, and global providers
