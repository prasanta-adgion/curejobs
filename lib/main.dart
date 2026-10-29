import 'package:flutter/material.dart';

import 'app/theme/app_colors.dart';
import 'features/splash/presentation/pages/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CureJobs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: Builder(
        builder: (context) => SplashPage(
          onFinished: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const _HomePlaceholder()),
          ),
        ),
      ),
    );
  }
}

// TODO: replace with the real home/onboarding screen.
class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Home')));
  }
}
