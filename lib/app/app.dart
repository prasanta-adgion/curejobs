import 'package:curejobs/features/appearance_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'theme/app_theme.dart';
import 'theme/theme_cubit.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/splash/presentation/pages/splash_page.dart';

class CureJobsApp extends StatelessWidget {
  const CureJobsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          title: 'CureJobs',
          debugShowCheckedModeBanner: false,

          // Global theme configuration
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,

          // Initial screen
          home: Builder(
            builder: (context) => SplashPage(
              onFinished: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (loginContext) => LoginPage(
                      onLoggedIn: (_) =>
                          Navigator.of(loginContext).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => const AppearancePage(),
                            ),
                          ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// class HomePage extends StatelessWidget {
//   const new({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

// Configure MaterialApp, themes, navigation, and global providers
