import 'package:flutter/material.dart';

import 'package:curejobs/app/theme/app_colors.dart';
import 'package:curejobs/shared/widgets/app_back_button.dart';

/// The page frame every step shares: navy "Get verified" app bar with a
/// step-specific [subtitle], the [body], and an optional pinned [bottomBar].
class VerificationScaffold extends StatelessWidget {
  const VerificationScaffold({
    super.key,
    required this.subtitle,
    required this.body,
    this.bottomBar,
  });

  final String subtitle;
  final Widget body;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: AppBackButton.leadingOf(context, color: AppColors.white),
        titleSpacing: 0,
        backgroundColor: AppColors.logoNavy,
        surfaceTintColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Get verified',
              style: TextStyle(color: AppColors.white),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: scheme.outlineVariant),
        ),
      ),
      body: body,
      bottomNavigationBar: bottomBar,
    );
  }
}

/// Stacks a step's sections, each on a white surface; the grey page shows
/// between them as bands.
class VerificationSections extends StatelessWidget {
  const VerificationSections({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final section in children)
          Material(color: surface, child: section),
      ],
    );
  }
}
