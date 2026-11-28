import 'package:flutter/material.dart';

import 'package:curejobs/features/profile/shared/widgets/profile_section.dart';

/// Icon tile with a title and a supporting line, used at the top of a step.
class VerificationHero extends StatelessWidget {
  const VerificationHero({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
    this.background,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color? color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        ProfileIconTile(
          icon: icon,
          size: 48,
          color: color,
          background: background,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
