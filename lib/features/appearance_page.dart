import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/theme_cubit.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  Future<void> _changeTheme(BuildContext context, ThemeMode mode) async {
    try {
      await context.read<ThemeCubit>().changeTheme(mode);
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save appearance preference.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, currentMode) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Choose your theme', style: textTheme.headlineMedium),

              const SizedBox(height: 8),

              Text(
                'Customize how CureJobs looks on your device.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 24),

              RadioGroup<ThemeMode>(
                groupValue: currentMode,
                onChanged: (mode) {
                  if (mode != null) {
                    _changeTheme(context, mode);
                  }
                },
                child: Column(
                  children: const [
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.system,
                      title: Text('System default'),
                      subtitle: Text('Follow your device appearance'),
                      secondary: Icon(Icons.brightness_auto_outlined),
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.light,
                      title: Text('Light mode'),
                      subtitle: Text('Use the light CureJobs theme'),
                      secondary: Icon(Icons.light_mode_outlined),
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.dark,
                      title: Text('Dark mode'),
                      subtitle: Text('Use the dark CureJobs theme'),
                      secondary: Icon(Icons.dark_mode_outlined),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registered Nurse – ICU',
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Healthcare job opportunity',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '₹25,000 – ₹40,000 / month',
                        style: textTheme.titleMedium?.copyWith(
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {},
                          child: const Text('Apply Now'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
