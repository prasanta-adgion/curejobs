import 'package:flutter/material.dart';

/// Branded top section: back button, logo, title and subtitle.
class RegistrationHeader extends StatelessWidget {
  const RegistrationHeader({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = scheme.onPrimary.withValues(alpha: 0.8);

    return Container(
      width: double.infinity,
      color: scheme.primary,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 72),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (onBack != null) ...[
              IconButton(
                onPressed: onBack,
                tooltip: 'Back',
                style: IconButton.styleFrom(
                  backgroundColor: scheme.onPrimary.withValues(alpha: 0.14),
                  foregroundColor: scheme.onPrimary,
                ),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.onPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.work_outline, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Text(
                  'CureJobs',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Create your account',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Join thousands of healthcare professionals',
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}
