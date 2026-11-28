import 'package:flutter/material.dart';

import '../common/verification_hero.dart';

/// Shown on the documents step before the upload form: what's about to
/// happen and what to keep handy. "Start verification" lives in the bottom
/// bar; [error] (from a failed start) shows here with a retry.
class VerificationStartCard extends StatelessWidget {
  const VerificationStartCard({super.key, this.error, this.onRetry});

  final String? error;
  final VoidCallback? onRetry;

  static const _steps = [
    (title: 'Choose a document type', subtitle: "Pick what you're uploading"),
    (
      title: 'Take a photo or pick a file',
      subtitle: 'PDF, JPG or PNG up to 5 MB',
    ),
    (title: 'Submit for review', subtitle: 'We check within 2 working days'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const VerificationHero(
          icon: Icons.verified_user_outlined,
          title: 'Ready to get verified?',
          subtitle: '3 simple steps, about 2 minutes.',
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < _steps.length; i++)
          _NumberedStep(
            number: i + 1,
            title: _steps[i].title,
            subtitle: _steps[i].subtitle,
          ),
        const SizedBox(height: 10),
        Divider(height: 1, color: scheme.outlineVariant),
        const SizedBox(height: 12),
        Text('Keep these handy', style: muted),
        const SizedBox(height: 8),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _HandyChip(icon: Icons.badge_outlined, label: 'Government ID'),
            _HandyChip(
              icon: Icons.workspace_premium_outlined,
              label: 'Medical licence',
            ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: 14),
          _StartError(message: error!, onRetry: onRetry),
        ],
      ],
    );
  }
}

/// Numbered circle with a title and a supporting line.
class _NumberedStep extends StatelessWidget {
  const _NumberedStep({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  final int number;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primaryContainer,
            ),
            child: Text(
              '$number',
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Red box with the start error and a Retry button.
class _StartError extends StatelessWidget {
  const _StartError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: scheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onErrorContainer,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: scheme.onErrorContainer,
              ),
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}

class _HandyChip extends StatelessWidget {
  const _HandyChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
